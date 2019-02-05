# -*- coding: utf-8 -*-
#***********************************************************************
# This file is part of OpenMolcas.                                     *
#                                                                      *
# OpenMolcas is free software; you can redistribute it and/or modify   *
# it under the terms of the GNU Lesser General Public License, v. 2.1. *
# OpenMolcas is distributed in the hope that it will be useful, but it *
# is provided "as is" and without any express or implied warranties.   *
# For more details see the full text of the license in the file        *
# LICENSE or in <http://www.gnu.org/licenses/>.                        *
#                                                                      *
# Copyright (C) 2015-2018, Ignacio Fdez. Galván                        *
#***********************************************************************
#
# This file is execfile()d with the current directory set to its
# containing dir.
#
# Note that not all possible configuration values are present in this
# autogenerated file.
#
# All configuration values have a default; values that are commented out
# serve to show the default.

import sys
import os

sys.dont_write_bytecode = True

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#sys.path.insert(0, os.path.abspath('.'))

sys.path.append(os.path.abspath('../extensions'))

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
needs_sphinx = '1.8'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.mathjax',
    #'sphinx.ext.pngmath',
    'sphinxcontrib.bibtex',
    #'rst2pdf.pdfbuilder',
    'transforms',
    'numsec',
    'xmldoc',
    'extractfile',
    'float',
    'molcasbib',
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix of source filenames.
source_suffix = '.rst'

# The encoding of source files.
#source_encoding = 'utf-8-sig'

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = u'Molcas'
copyright = u'2017–2019, MOLCAS Team'

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y version.
version = os.environ.get('OPENMOLCAS_VERSION', 'unknown')
# The full version, including alpha/beta/rc tags.
release = os.environ.get('OPENMOLCAS_RELEASE', 'unknown')

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#language = None

# There are two options for replacing |today|: either, you set today to some
# non-false value, then it is used:
#today = ''
# Else, today_fmt is used as the format for a strftime call.
#today_fmt = '%B %d, %Y'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = ['tutorials/tut_alaska.rst']

# The reST default role (used for this markup: `text`) to use for all
# documents.
#default_role = None

# If true, '()' will be appended to :func: etc. cross-reference text.
#add_function_parentheses = True

# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
#add_module_names = True

# If true, sectionauthor and moduleauthor directives will be shown in the
# output. They are ignored by default.
#show_authors = False

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# A list of ignored prefixes for module index sorting.
#modindex_common_prefix = []

# If true, keep warnings as "system message" paragraphs in the built documents.
#keep_warnings = False


# -- Options for HTML output ----------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = 'molcas'
html_theme_options = {
  'pdf_file': os.environ.get('PDF_FILE', '')
#    'rightsidebar': 'false',
#    'stickysidebar': 'true'
}

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#html_theme_options = { }

# Add any paths that contain custom themes here, relative to this directory.
html_theme_path = ['_theme']

# The name for this set of Sphinx documents.  If None, it defaults to
# "<project> v<release> documentation".
html_title = 'Molcas Manual (version {})'.format(version)

# A shorter title for the navigation bar.  Default is the same as html_title.
html_short_title = '<span class="sc">Molcas</span> Manual (version {})'.format(release)

# The name of an image file (relative to this directory) to place at the top
# of the sidebar.
html_logo = '_static/logo.png'

# The name of an image file (within the static path) to use as favicon of the
# docs.  This file should be a Windows icon file (.ico) being 16x16 or 32x32
# pixels large.
html_favicon = '_static/favicon.ico'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# Add any extra paths that contain custom files (such as robots.txt or
# .htaccess) here, relative to this directory. These files are copied
# directly to the root of the documentation.
#html_extra_path = []

# If not '', a 'Last updated on:' timestamp is inserted at every page bottom,
# using the given strftime format.
#html_last_updated_fmt = '%b %d, %Y'

# Custom sidebar templates, maps document names to template names.
#html_sidebars = {}

# Additional templates that should be rendered to pages, maps page names to
# template names.
#html_additional_pages = {}

# If false, no module index is generated.
#html_domain_indices = True

# If false, no index is generated.
#html_use_index = True

# If true, the index is split into individual pages for each letter.
#html_split_index = False

# If true, links to the reST sources are added to the pages.
html_show_sourcelink = True

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
#html_show_sphinx = True

# If true, "(C) Copyright ..." is shown in the HTML footer. Default is True.
#html_show_copyright = True

# If true, an OpenSearch description file will be output, and all pages will
# contain a <link> tag referring to it.  The value of this option must be the
# base URL from which the finished HTML is served.
#html_use_opensearch = ''

# This is the file name suffix for HTML files (e.g. ".xhtml").
#html_file_suffix = None

# Output file base name for HTML help builder.
htmlhelp_basename = 'Molcasdoc'

# -- Options for LaTeX output ---------------------------------------------

latex_elements = {
# The paper size ('letterpaper' or 'a4paper').
#'papersize': 'letterpaper',

# The font size ('10pt', '11pt' or '12pt').
#'pointsize': '10pt',

# Additional stuff for the LaTeX preamble.
#'preamble': '',

# Maketitle command
  'maketitle': '\maketitle',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
  (master_doc, 'Manual.tex', u'Molcas Manual\\\\(version {})'.format(release), u'MOLCAS Team', 'memoir'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
#latex_logo = None

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
#latex_use_parts = True

# If true, show page references after internal links.
#latex_show_pagerefs = True

# If true, show URL addresses after external links.
#latex_show_urls = False

# Documents to append as an appendix to all manuals.
#latex_appendices = []

# If false, no module index is generated.
#latex_domain_indices = True


# -- Options for manual page output ---------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (master_doc, 'molcas', u'Molcas Documentation',
     [u'MOLCAS Team'], 1)
]

# If true, show URL addresses after external links.
#man_show_urls = False


# -- Options for Texinfo output -------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
texinfo_documents = [
  (master_doc, 'Molcas', u'Molcas Documentation',
   u'MOLCAS Team', 'Molcas', 'One line description of project.',
   'Miscellaneous'),
]

# Documents to append as an appendix to all manuals.
#texinfo_appendices = []

# If false, no module index is generated.
#texinfo_domain_indices = True

# How to display URL addresses: 'footnote', 'no', or 'inline'.
#texinfo_show_urls = 'footnote'

# If true, do not generate a @detailmenu in the "Top" node's menu.
#texinfo_no_detailmenu = False


# -- Options for PDF output --------------------------------------------------

# Grouping the document tree into PDF files. List of tuples
# (source start file, target name, title, author, options).
#
# If there is more than one author, separate them with \\.
# For example: r'Guido van Rossum\\Fred L. Drake, Jr., editor'
#
# The options element is a dictionary that lets you override
# this config per-document.
# For example,
# ('index', u'MyProject', u'My Project', u'Author Name',
#  dict(pdf_compressed = True))
# would mean that specific document would be compressed
# regardless of the global pdf_compressed setting.

pdf_documents = [
    ('manual', 'Molcas', u'Molcas Documentation', u'MOLCAS Team', None),
]

# A comma-separated list of custom stylesheets. Example:
#pdf_stylesheets = ['sphinx','kerning','a4']

# A list of folders to search for stylesheets. Example:
#pdf_style_path = ['.', '_styles']

# Create a compressed PDF
# Use True/False or 1/0
# Example: compressed=True
#pdf_compressed = False

# A colon-separated list of folders to search for fonts. Example:
# pdf_font_path = ['/usr/share/fonts', '/usr/share/texmf-dist/fonts/']

# Language to be used for hyphenation support
#pdf_language = "en_US"

# Mode for literal blocks wider than the frame. Can be
# overflow, shrink or truncate
#pdf_fit_mode = "shrink"

# Section level that forces a break page.
# For example: 1 means top-level sections start in a new page
# 0 means disabled
#pdf_break_level = 0

# When a section starts in a new page, force it to be 'even', 'odd',
# or just use 'any'
#pdf_breakside = 'any'

# Insert footnotes where they are defined instead of
# at the end.
#pdf_inline_footnotes = True

# verbosity level. 0 1 or 2
#pdf_verbosity = 0

# If false, no index is generated.
#pdf_use_index = True

# If false, no modindex is generated.
#pdf_use_modindex = True

# If false, no coverpage is generated.
#pdf_use_coverpage = True

# Name of the cover page template to use
#pdf_cover_template = 'sphinxcover.tmpl'

# Documents to append as an appendix to all manuals.
#pdf_appendices = []

# Enable experimental feature to split table cells. Use it
# if you get "DelayedTable too big" errors
#pdf_splittables = False

# Set the default DPI for images
#pdf_default_dpi = 72

# Enable rst2pdf extension modules (default is only vectorpdf)
# you need vectorpdf if you want to use sphinx's graphviz support
#pdf_extensions = ['vectorpdf']

# Page template name for "regular" pages
#pdf_page_template = 'cutePage'

# Show Table Of Contents at the beginning?
#pdf_use_toc = True

# How many levels deep should the table of contents be?
#pdf_toc_depth = 9999

# Add section number to section references
#pdf_use_numbered_links = False

# Background images fitting mode
#pdf_fit_background_mode = 'scale'


# -- Additional options ---------------------------------------------------

primary_domain = ''
highlight_language = 'none'
rst_prolog = open('definitions.sb', 'r').read()
html_compact_lists = True

numfig = True
numfig_secnum_depth = 3
numfig_format = {'figure': 'Figure %s',
                 'table': 'Table %s',
                 'code-block': 'Block %s'}

latex_toplevel_sectioning = 'part'
latex_elements['papersize'] = 'a4paper'
latex_elements['pointsize'] = '12pt'
latex_elements['fncychap'] = ''
latex_elements['utf8extra'] = r'\DeclareUnicodeCharacter{00A0}{\nobreakspace}'\
                              r'\DeclareUnicodeCharacter{2212}{\textminus}'\
                              r'\DeclareUnicodeCharacter{200B}{\relax}'
latex_elements['fontpkg'] = r'\usepackage[notextcomp]{kpfonts}'
latex_elements['preamble'] = r'''\usepackage{molcas}
\pagestyle{plain}
\setsecnumdepth{subparagraph}
\renewcommand{\thepart}{\arabic{part}}
\numberwithin{chapter}{part}
\setlength\cftchapternumwidth{2em}
\setlength\cftsectionindent{2em}
\setlength\cftsectionnumwidth{3.5em}
\nobibintoc
\renewcommand{\bibsection}{\relax}
\frenchspacing'''
latex_additional_files = [ '_latex/molcas.sty' ]

pngmath_dvipng_args = ['-Q', '10']
pngmath_use_preview = True
pngmath_latex_preamble = r'''\usepackage{amsmath,mhchem,kpfonts}
\DeclareMathOperator{\sign}{sign}
\DeclareMathOperator{\abs}{abs}
\DeclareMathOperator{\Tr}{Tr}
\newcommand{\mat}[1]{\boldsymbol{#1}}
\newcommand{\bra}[1]{\left<#1\right|}
\newcommand{\ket}[1]{\left|#1\right>}
\newcommand{\braket}[2]{\left<#1\middle|#2\right>}
\newcommand{\braopket}[3]{\left<#1\middle|#2\middle|#3\right>}'''

# xmldoc extension:
data_dir = 'data'

# extractfile extension:
extract_dir = 'samples'

# references extension:
ref_file = 'references'

def setup(app):
    app.add_css_file('fonts.css')
    app.add_css_file('style.css')
    app.add_css_file('colors.css', title='Default')
    app.add_css_file('nocolors.css', title='No colors', rel='alternate stylesheet')
    app.add_css_file('specific.css')
    app.add_js_file('styleswitcher.js')
    app.add_js_file('functions.js')
    app.add_js_file('mathjax_config.js')
