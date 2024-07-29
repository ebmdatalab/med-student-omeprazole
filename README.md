# The Bennett Institute's skeleton notebook environment


## Getting started with this skeleton project

This is a skeleton project for creating a reproducible, cross-platform
analysis notebook, using Docker.

Developers and analysts using this skeleton for new development should
refer to [`DEVELOPERS.md`](DEVELOPERS.md) for instructions on getting
started.  Update this `README.md` so it is a suitable introduction to
your project.


## Running Jupyter Lab

You will need to have installed Git and Docker, please see the
[`INSTALLATION_GUIDE.md`](INSTALLATION_GUIDE.md) for further details.

Windows and Linux users should double-click the `jupyter-lab` file.
Users on macOS should double-click `jupyter-lab-mac-os` instead.

Note: if double-clicking the `jupyter-lab` file opens the file in VS Code, you
should instead right-click on the file and open it with Git for Windows.

This will build a Docker image with all software requirements installed,
start a new Jupyter Lab server, and then provide a link to access this
server.

The first time you run this command it may take some time to download
and install the necessary software. Subsequent runs should be much
faster.

Note: if running the command fails with:

```
docker: Error response from daemon: user declined directory sharing C:\path\to\directory
```

you should open the Docker dashboard, and then under Settings -> Resources ->
FileSharing, add the appropriate path.


## How to cite

XXX Please change to either a paper (if published) or the repo. You may find it helpful to use Zenodo DOI (see [`DEVELOPERS.md`](DEVELOPERS.md#how-to-invite-people-to-cite) for further information)
