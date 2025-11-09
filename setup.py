from setuptools import find_packages, setup

setup(
    name="cyc",
    packages=find_packages(),

    install_requires=[
        'transformers',
        'torch',
        'scikit-learn',
        'numpy',
        'pandas',
        'torchaudio',
        'torchvision',
        'biopython',
    ],
    
    entry_points={
        "console_scripts": [
            "bgf=cyc.inference:main",
        ],
    },
)
