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
