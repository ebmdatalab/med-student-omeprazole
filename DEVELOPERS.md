# The Bennett Institute's default notebook environment


## Running Jupyter Lab

You will need to have installed Git and Docker, please see the
[`INSTALLATION_GUIDE.md`](INSTALLATION_GUIDE.md) for further details.

Windows and Linux users should double-click the `jupyter-lab` file.
Users on macOS should double-click `jupyter-lab-mac-os` instead.

This will build a Docker image with all software requirements installed,
start a new Jupyter Lab server, and then provide a link to access this
server.

The first time you run this command it may take some time to download
and install the necessary software. Subsequent runs should be much
faster.


## Adding or updating Python packages

To install a new package:

 * Add it to the bottom of the `requirements.in` file.
 * From the Jupyter Labs Launcher page, choose "Terminal" (in the
   "Other" section).
 * Run:
   ```sh
   pip-compile -v
   ```
   This will automatically update your `requirements.txt` file to
   include the new package. (The `-v` just means "verbose" so you can
   see progess as this command can take a while to run.)
 * Shutdown the Jupyter server and re-run the `jupyter-lab` launcher
   script.
 * Docker should automatically install the new package before starting
   the server.

To update an existing package the process is the same as above except
that instead of running `pip-compile -v` you should run:
```sh
pip-compile -v --upgrade-package <package_name>
```

To update _all_ packages you can run:
```sh
pip-compile -v --upgrade
```


## Importing from `lib`

We used to have configuration which made Python files in the top-level
`lib` directory importable. However this did not work reliably and users
developed a variety of different workarounds. We now no longer make any
changes to Python's default import behaviour. Depending on what
workarounds you already have in place this may make no difference to
you, or it may break your imports.

If you find your imports no longer work and you have imports of the
form:
```python
from lib import my_custom_library
```
Then you should move the `lib` directory to be inside `notebooks` and it
should work.

If your imports no longer work and they are of the form:
```python
import my_custom_library
```
Then you can move `lib/my_custom_library.py` to
`notebooks/my_custom_library.py`.


## Diffing notebook files

By default, changes to `.ipynb` files do not produce easily readable
diffs in Github. One solution is to enable the "[Rich Jupyter Notebook
Diffs][richdiff]" preview feature. You can find this by clicking your
account icon in top right of the Github interface, choosing "Feature
preview", then "Rich Jupyter Notebooks Diffs" and then "Enable".

[richdiff]: https://github.blog/changelog/2023-03-01-feature-preview-rich-jupyter-notebook-diffs/

Another option is to use [Jupytext][jupytext], which we have pre-added to the
list of installed packages. You can use either the `percent` or
`markdown` formats to create notebooks which have naturally readable
diffs, at the cost of not being able to save the outputs of cells within
the notebook.

[jupytext]: https://jupytext.readthedocs.io/en/latest/

To use the "paired" format in which a traditional `.ipynb` file is saved
alongside a pure-Python variant inside a `diffable_python` directory,
add a file called `jupytext.toml` to the root of your repo containing
these lines:
```toml
[formats]
"notebooks/" = "ipynb"
"notebooks/diffable_python/" = "py:percent"
```

To prevent `.ipynb` files from showing in Github diffs add these lines
to the bottom of the `.gitattributes` files:
```
# Don't show notebook files when diffing in GitHub
notebooks/**/*ipynb linguist-generated=true
```


## How to invite people to cite

Once a project is completed, please use the instructions [here](https://guides.github.com/activities/citable-code/) to deposit a copy of your code with Zenodo. You will need a Zenodo free account to do this. This creates a DOI. Once you have this please add this in the readme.

If there is a paper associated with this code, please change the 'how to cite' section to the citation and DOI for the paper. This allows us to build up citation credit.
