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
