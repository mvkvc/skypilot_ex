Mix.install([
  {:exla, "~> 0.5.1"},
  {:nx, "~> 0.5.1"},
  {:explorer, "~> 0.5.0"},
  {:axon, "~> 0.5.1"},
  {:bumblebee, "~> 0.3.0"}
])

args = System.argv()

{options, _, _} =
  OptionParser.parse(args, strict: [train: :string, test: :string, output: :string])

path_train = options[:train]
path_test = options[:test]
path_output = options[:output]

IO.inspect(path_train, label: "path_train")
IO.inspect(path_test, label: "path_test")
IO.inspect(path_output, label: "path_output")

model_id = "bert-base-cased"
batch_size = 32
sequence_length = 64
lr = 5.0e-5

Nx.default_backend(EXLA.Backend)

{:ok, spec} =
  Bumblebee.load_spec({:hf, model_id},
    architecture: :for_sequence_classification
  )

spec = Bumblebee.configure(spec, num_labels: 2)

{:ok, model} = Bumblebee.load_model({:hf, model_id}, spec: spec)
{:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, model_id})

defmodule Spam do
  def load(path, tokenizer, opts \\ []) do
    path
    |> Explorer.DataFrame.from_csv!(header: true)
    |> Explorer.DataFrame.rename(["text", "label"])
    |> stream()
    |> tokenize_and_batch(tokenizer, opts[:batch_size], opts[:sequence_length])
  end

  def stream(df) do
    xs = df["text"]
    ys = df["label"]

    xs
    |> Explorer.Series.to_enum()
    |> Stream.zip(Explorer.Series.to_enum(ys))
  end

  def tokenize_and_batch(stream, tokenizer, batch_size, sequence_length) do
    stream
    |> Stream.chunk_every(batch_size)
    |> Stream.map(fn batch ->
      {text, labels} = Enum.unzip(batch)
      # labels = Nx.stack(labels)
      # {labels_size} = Nx.shape(labels)
      # labels_resized = if labels_size == batch_size, do: batch_size, else: labels_size
      # labels = Nx.reshape(labels, {labels_resized, 1})
      tokenized = Bumblebee.apply_tokenizer(tokenizer, text, length: sequence_length)
      # {tokenized, labels}
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

IO.inspect(Enum.take(train_data, 1))

%{model: model, params: params} = model

IO.inspect(model, label: "model")

[{input, _}] = Enum.take(train_data, 1)
Axon.get_output_shape(model, input) |> IO.inspect(label: "output_shape")

logits_model =
  model
  |> Axon.nx(& &1.logits)

# |> Axon.nx(&Nx.argmax(&1, axis: 1))
# |> Axon.nx(&Nx.reshape(&1, {batch_size, 1}))
# |> Axon.nx(fn x ->
#   {size} = Nx.shape(x)
#   Nx.reshape(x, {size, 1})
# end)

# loss = &Axon.Losses.binary_cross_entropy(&1, &2, reduction: :mean, from_logits: true)
loss =
  &Axon.Losses.categorical_cross_entropy(&1, &2, reduction: :mean, from_logits: true, sparse: true)

optimizer = Axon.Optimizers.adam(lr)
loop = Axon.Loop.trainer(logits_model, loss, optimizer, log: 1)

accuracy = &Axon.Metrics.accuracy(&1, &2, from_logits: true, sparse: true)
loop = Axon.Loop.metric(loop, accuracy, "accuracy")

train_data = Enum.take(train_data, 300)
test_data = Enum.take(test_data, 100)

trained_model_state =
  logits_model
  |> Axon.Loop.trainer(loss, optimizer, log: 1)
  |> Axon.Loop.metric(accuracy, "accuracy")
  |> Axon.Loop.run(train_data, params, epochs: 3, compiler: EXLA, strict?: false)

logits_model
|> Axon.Loop.evaluator()
|> Axon.Loop.metric(accuracy, "accuracy")
|> Axon.Loop.run(test_data, trained_model_state, compiler: EXLA)

%{model: model, params: params} = trained_model_state
params_ser = Nx.serialize(params)
File.write!(path_output, params_ser)
