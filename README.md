---
title: Changing Times
author: Thomas W. Wong Hearing
date: 07 May 2026
---

# What is Changing Times?
*Changing Times* is an interactive tool for understanding, quantifying, and visualising the differences between stratigraphic age models. 
I initially developed this tool to provide an intuitive way of seeing how age models for the Ediacaran-Cambrian transition (~580 to 510 million years ago) have changed in recent years. 
This beta release of *Changing Times* is still in development and may change without notice until a first major version is released. 
There are two built-in datasets: one for Ediacaran-Cambrian carbon isotope chronostratigraphy developed by Fred Bowyer, and one for the Miocene geomagnetic polarity timescale developed by Anna Joy Drury. 
The app is designed to be flexible and adaptable to other types of data and age models. 
If you find that your data do not work in the way you expect, please [contact me](mailto:twonghearing@gmail.com). 

# How can Changing Times help me? 
When working with temporal data it is important to make sure you are measuring datasets in the same temporal reference frame. 
However, age models change over time as new data and methods become available. 
Both acknowledged and unknown uncertainties associated with age models can be large, especially when working with deep time data, and can significantly affect dataset interpretations.
*Changing Times* helps to visualise and quantify the changes between different age model iterations, showing which time intervals have been most affected from one version to another. 
Overall, this can help show how stable age models are, and which time intervals may be subject to reinterpretation as chronostratigraphic methods and frameworks develop.

# What data format does Changing Times need? 
Uploaded files must be **".xlsx"** or **".csv"** format, with one row per datum (e.g. an isotope sample, a fossil first/last appearance, or a magnetochron boundary). 
The following columns are required:
- One or more **numeric** age-model columns whose names start with **"Model_"** (e.g. **"Model_CK1995"**, **"Model_GTS2020"**); leave cells blank or with "NA" if a datum does not have an age in a given age model. 
- At least one additional column to plot (e.g. numeric for an isotope plot, any value such as isochron id for an isochron plot).
- For magnetostratigraphy-style data, also include two text columns named **"Magnetochron_base"** and **"Magnetochron_top"**. Magnetochron_base is the younger chron, the one with its base at this age; Magnetochron_top is the older chron, the one with its top at this age. Polarity is inferred from chron names ending in **"n"** for **" normal"** or **"r"** for **"reversed"**.

# What's coming next? 
*Changing Times* ss still in development and this should be regarded as a beta release. 
Please [contact me](mailto:twonghearing@gmail.com) if there are specific features you'd like to see.
I am planning to include an option for saving out tables of datapoint/event age volatility, as well as options to download the code used for specific calculations and plot rendering. 
