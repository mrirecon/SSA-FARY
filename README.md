These scripts reproduce the experiments described in the article:

Rosenzweig S, Scholand N, Holme HCM, Uecker M. <br>
 **Cardiac and Respiratory Self-Gating in Radial MRI using an Adapted Singular Spectrum Analysis (SSA-FARY)**. <br>
IEEE Trans Med Imag 2020, Early Access, DOI: 10.1109/TMI.2020.2985994 [1,2]

The algorithms have been integrated into the Berkeley Advanced Reconstruction Toolbox (BART) [3] (commit 737082541c).

The raw files are hosted on ZENODO and must be downloaded first
- Manual download: https://zenodo.org/record/3822451
- Download via script: Run the download script in the _./data_ folder.
  - All files: `bash load_all.sh` 
  - Individual files: `bash load.sh 3822451 <FILENAME> .` (<FILENAME> without file extension. Then extract the *.tgz)
- Note: The data must be stored in the _./data_ folder

The other folders contain:
- _run.sh_ scripts, which perfoms the image reconstruction
- _plot.sh_ scripts, which create the Figures
- _makemovie.sh_ scripts, which create the movie files
- some _*.py_ scripts for plotting tasks
- and a _results_ folder, with images and movies that serve as reference

To run the scripts _GNU Bash_ [4] is required.

The data can be viewed e.g. with 'view'[5] or be loaded into Matlab or Python
using the wrappers provided in BART subdirectories './matlab' and './python'

To reproduce the plots and figures _python3_ [6], the 'cfl2png' command from
__view_ [5], and 'convert' from _imagemagick_ [7] and the Linux Biolinum font [8]
are required. The font can be downloaded by running the _get_font.sh_ script
in the _utils_ folder. To create the movies _ffmpeg_ [9] is used.

Please note that BART with GPU support is required.
Running all scripts will take more than 24 hours, even on a multi-core compute system!


If you need further help to run the scripts, I am happy to help you: sebastian.rosenzweig@med.uni-goettingen.de

Mai 14, 2020 - Sebastian Rosenzweig

[1] https://ieeexplore.ieee.org/document/9057630 (DOI: 10.1109/TMI.2020.2985994, early access)
[2] https://arxiv.org/abs/1812.09057v6
[3] https://mrirecon.github.io/bart
[4] https://www.gnu.org/software/bash/
[5] https://github.com/mrirecon/view
[6] https://www.python.org
[7] https://imagemagick.org
[8] https://www.fontsquirrel.com/fonts/linux-biolinum
[9] https://ffmpeg.org
