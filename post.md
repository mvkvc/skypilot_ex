# Post

Blog post for this project.

## Setup

When installing pip CLI utils in a non-python project I enjoy using pipx which creates a sandboxed python environment for each CLI util. This is a great way to keep your system python clean and avoid dependency conflicts.

Install it here

<https://pypa.github.io/pipx/>

Then install skypiloy according to the instructions here

<https://skypilot.readthedocs.io/en/latest/getting-started/installation.html>

Add the cloud vendor you want it to be able to use ex.

```bash
pipx install "skypilot[aws,gcp,azure,lambda]"
```

Now it should be availble on your command line

```bash
skypilot --help
```

CLOUD ACCOUNT SETUP

REVISIT

We are using this example as a reference from the SkyPilot repo

<https://github.com/skypilot-org/skypilot/blob/master/examples/docker/echo_app.yaml>

Machine learning problem

Let's train a model to predict spam emails.

<https://www.kaggle.com/datasets/nitishabharathi/email-spam-dataset>

How are we going to do this?

Let's fine tune a BERT model to do this.

First create a mix project ->>> mix new skypilot_ex

Add these to your deps

{:exla, "~> 0.5.1"},
{:nx, "~> 0.5.1"},
{:explorer, "~> 0.5.0"},
{:axon, "~> 0.5.1"},
{:bumblebee, "~> 0.3.0"}

Install livebook

mix do local.rebar --force, local.hex --force
mix escript.install hex livebook 0.9.2

First lets explore the data and and try to combine the data into a single csv file.

In the setup you can add Mix.install([{:skypilot_ex, path: "."}]) to download all the dependencies.

Then you can use the module in the livebook

All datasets have the same Body string and Label integer columns so we can combine them into a single csv file.

- Select Body and LAbel only
- concat_rows
- shuffle

Now lets create train and test datasets to two csvs

you can see the code in the csv livebook

<!-- You can sync the files locally directyl to the VM but lets use skypilot to sync them to a cloud storage bucket. -->

Let's write the code to train the model in a livebook, and we will copy it to an exs file later.

We will fine tune a BERT model to do this similar to the example here (<https://hexdocs.pm/bumblebee/fine_tuning.html>).

Create the storage bucket in your cloud account (dont have to actually itll be created just make it unique)

Put code here from training
Logits means probability values

Talk about how to change axon output sto maatch and waht you had to do

Not using AWS because IAM is annoying
