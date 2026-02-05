# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import datetime
import subprocess
from pathlib import Path


# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "MATLAB Access Layer"
copyright = f"{datetime.datetime.now().year}, ITER Organization"
author = "ITER Organization"

# Get version from git describe, with fallback if no tags exist
try:
    version = subprocess.check_output(["git", "describe"], stderr=subprocess.DEVNULL).decode().strip()
except subprocess.CalledProcessError:
    # If git describe fails (no tags), use a default version
    version = "development"

# Get last tag for develop check, with fallback
try:
    last_tag = subprocess.check_output(["git", "describe", "--abbrev=0"], stderr=subprocess.DEVNULL).decode().strip()
except subprocess.CalledProcessError:
    # If no tags exist, we're in development
    last_tag = None

is_develop = last_tag is None or version != last_tag

html_context = {
    "is_develop": is_develop
}

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx.ext.todo",
    "sphinx.ext.autosectionlabel",
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "sphinx.ext.mathjax",
    "sphinx.ext.napoleon",
    "sphinx_immaterial",
    "sphinxcontrib.matlab",
]

# todo_include_todos = True

# Note: exclude doc_common and plugins folders (which are symlinked by the CMake build)
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store", "doc_common", "plugins"]

# -- RST snippets to include in every page -----------------------------------
rst_epilog = """\
.. |DD| replace:: `Data Dictionary`_
.. _`Data Dictionary`: https://sharepoint.iter.org/departments/POP/CM/IMDesign/Data%20Model/CI/Latest.html
"""

# -- sphinxcontrib.matlab configuration --------------------------------------
# https://github.com/sphinx-contrib/matlabdomain#configuration

matlab_src_dir = str(Path(__file__).parent.parent / "matlab")
matlab_short_links = True
matlab_auto_link = "all"

# -- Intersphinx configuration -----------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html#configuration

intersphinx_mapping = {
    # 'python': ('https://docs.python.org/3', None),
    # 'numpy': ('https://numpy.org/doc/stable/', None),
}


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output


html_theme = "sphinx_immaterial"
html_theme_options = {
    "repo_url": "https://git.iter.org/projects/IMAS/repos/access-layer",
    "repo_name": "Access Layer",
    "icon": {
        "repo": "fontawesome/brands/bitbucket",
    },
    "features": [
        # "navigation.expand",
        # "navigation.tabs",
        "navigation.sections",
        "navigation.instant",
        # "header.autohide",
        "navigation.top",
        # "navigation.tracking",
        # "search.highlight",
        # "search.share",
        # "toc.integrate",
        "toc.follow",
        "toc.sticky",
        # "content.tabs.link",
        "announce.dismiss",
    ],
    # "toc_title_is_page_title": True,
    # "globaltoc_collapse": True,
    "palette": [
        {
            "media": "(prefers-color-scheme: light)",
            "scheme": "default",
            "primary": "indigo",
            "accent": "green",
            "toggle": {
                "icon": "material/lightbulb-outline",
                "name": "Switch to dark mode",
            },
        },
        {
            "media": "(prefers-color-scheme: dark)",
            "scheme": "slate",
            "primary": "light-blue",
            "accent": "lime",
            "toggle": {
                "icon": "material/lightbulb",
                "name": "Switch to light mode",
            },
        },
    ],
    "version_dropdown": True,
    "version_json": "../versions.js",
}

object_description_options = [
    (".*", dict(include_fields_in_toc=False)),
    (".*Param", dict(include_in_toc=False)),
]

html_static_path = ["./doc_common/static"]

sphinx_immaterial_generate_extra_admonitions = True
sphinx_immaterial_custom_admonitions = [
    {
        "name": "output",
        "color": (245, 98, 245),
        "icon": "fontawesome/solid/terminal",
    },

]
