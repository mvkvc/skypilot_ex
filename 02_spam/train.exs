Mix.install([
  {:exla, "~> 0.5.1"},
  {:nx, "~> 0.5.1"},
  {:explorer, "~> 0.5.0"},
  {:axon, "~> 0.5.1"},
  {:bumblebee, "~> 0.3.0"}
])

alias Explorer.DataFrame, as: DF
alias Explorer.Series

args = System.argv()

{options, _, _} =
  OptionParser.parse(args, strict: [train: :string, test: :string, output: :string])

path_train = options[:train]
path_test = options[:test]
path_output = options[:output]

IO.inspect(path_train, label: "path_train")
IO.inspect(path_test, label: "path_test")
IO.inspect(path_output, label: "path_output")

Nx.default_backend(EXLA.Backend)

model_id = "bert-base-cased"
batch_size = 32
sequence_length = 64
lr = 5.0e-5

{:ok, spec} =
  Bumblebee.load_spec({:hf, model_id},
    architecture: :for_sequence_classification
  )

spec = Bumblebee.configure(spec, num_labels: 2)

{:ok, model} = Bumblebee.load_model({:hf, model_id}, spec: spec)
{:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, model_id})

defmodule Spam do
  def load(path, tokenizer, opts \\ []) do
    df =
      path
      |> DF.from_csv!(header: true)
      |> DF.rename(["text", "label"])

    len = DF.n_rows(df)
    len = len - rem(len, opts[:batch_size])
    df = DF.slice(df, 0..(len - 1))

    df
    |> stream()
    |> tokenize_and_batch(tokenizer, opts[:batch_size], opts[:sequence_length])
  end

  def stream(df) do
    xs = df["text"]
    ys = df["label"]

    xs
    |> Series.to_enum()
    |> Stream.zip(Series.to_enum(ys))
  end

  def tokenize_and_batch(stream, tokenizer, batch_size, sequence_length) do
    stream
    |> Stream.chunk_every(batch_size)
    |> Stream.map(fn batch ->
      {text, labels} = Enum.unzip(batch)
      tokenized = Bumblebee.apply_tokenizer(tokenizer, text, length: sequence_length)
      {tokenized, Nx.stack(labels)}
    end)
  end
end

train_data =
  Spam.load(path_train, tokenizer,
    batch_size: batch_size,
    sequence_length: sequence_length
  )

test_data =
  Spam.load(path_test, tokenizer,
    batch_size: batch_size,
    sequence_length: sequence_length
  )

%{model: model, params: params} = model

logits_model = Axon.nx(model, & &1.logits)

loss =
  &Axon.Losses.categorical_cross_entropy(&1, &2, reduction: :mean, from_logits: true, sparse: true)

optimizer = Axon.Optimizers.adam(lr)
loop = Axon.Loop.trainer(logits_model, loss, optimizer, log: 1)

accuracy = &Axon.Metrics.accuracy(&1, &2, from_logits: true, sparse: true)
loop = Axon.Loop.metric(loop, accuracy, "accuracy")

IO.puts("\nTraining...")

trained_model_state =
  logits_model
  |> Axon.Loop.trainer(loss, optimizer, log: 1)
  |> Axon.Loop.metric(accuracy, "accuracy")
  |> Axon.Loop.run(train_data, params, epochs: 3, compiler: EXLA, strict?: false)

IO.puts("\nTesting...")

logits_model
|> Axon.Loop.evaluator()
|> Axon.Loop.metric(accuracy, "accuracy")
|> Axon.Loop.run(test_data, trained_model_state, compiler: EXLA)

IO.puts("\nSaving...")

params_ser = Nx.serialize(trained_model_state)
File.write!(path_output, params_ser)
