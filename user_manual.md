COPODA
======
User manual v1.0
----------------
Guillaume Maze
--------------

Introdution
===========

**COPODA** stands for COllaborative Package for Ocean Data Analysis. It is a Matlab package to manage, manipulate and work with hydrographic data from miscellaneous formats and origins. The core principle of **COPODA** is that the scientific analysis should not depend on the data format. Computing a heat content or a mixed layer depth should not depend on the platform measuring temperature.

Available hydrographic data are distributed in many different formats (such as netcdf, grib, mat, hsv, etc ...) and sometimes using different conventions. Although they are very large database aiming at uniforming such data (Hydrobase for instance), scientists - and some operators - often have to compare, merge and work with informations coming from different sources and therefore have to develop custom routines to perform standard diagnostics. **The primary goal of COPODA is to provide an uniform and collaborative platform for diagnostics development under Matlab**. **COPODA** is a framework to develop and use diagnostics independently of the data format such as illustrated in the following schematic: ![Schematic of COPODA][copoda-scheme]

## Usage scenario

Imagine that you have data from three hydrographic campaigns like OVIDE 2002, 2004 and 2006. You have these data as 3 netcdf files interpolated on a standard vertical grid with a 1 meter resolution. You would be able to develop, perform and compare diagnostics with these campaigns, using indifferently the 3 files, simply because they all have the same format. 
Now let's imagine the following scenario:

* you'd like to compare a diagnostic result based on oxygen data from OVIDE campaigns to results based on data from another dataset, such as the CARINA database which is a text file with bottle samples values on an irregular grid.
* you'd like to run another diagnostic you developed a few years ago when you were working on data from another campaign. But this diagnostic was for a different data format (no netcdf or no vertical interpolation). Moreover at this time, you were working with oxygen data in ml/l and now you use mumol/kg.	
* you'd like to simply compare OVIDE campaigns profiles to the World Ocean Atlas.

In the first situation you would have to interpolate and convert CARINA data to match OVIDE format. In the second situation you would have to re-write your diagnostics and manage the unit conversion. In the the third situation you would have to interpolate the WOA data and again manage different grid and file formats.

With **COPODA**, these painful scenario would be tackled easily because COPODA help you to work  within an uniform framework that you define. **COPODA** is able to perform under the hood and automatically in a few seconds most of the borrowing tasks necessary to handle the above scenarios, allowing you to focus on diagnostics improvements and physics, finally improving your productivity.

The **COPODA** framework is based on 3 fundamental new objects in Matlab:

* **odata** (Object Data) is the core object to hold measurements and their meta data (think of it as a netcdf variable with attributes).
* **transect**: is an object dedicated to the manipulation of a collection of measurements, organized as odata objects. A transect object contains information about a collection of measurements (eg: from one autonomous Argo profilers or from a given hydrographic campaign). A transect object will contain information about the geo-localization of the data, the platform, the cruise and will hold the data themself. Although this mix of meta and raw informations looks very similar to a netcdf file, its use is more powerful as it will be illustrated in the following sections. 
* **database**: is an object dedicated to the manipulation of a collection of transect objects. A database object could contain all the campaigns data from one institute or for a geographical region or time period.

In the following documentation will describe these 3 objects and the functions available to work with them. As those objects are implemented as new Matlab classes, we’ll first introduce this concept. A guideline will finally describe how to take advantage of the framework for your environment.

Matlab classes: a brief overview
================================

In the Matlab language, each entity, object or value (whatever you name it) is defined by the class it belongs to. The class will determine how it is printed in the command window or how two entities can be summed or multiplied or concatenated.
Matlab is smart, so for instance, when you create a new variable with an assignment statement (the operator `=`), it constructs a new variable of the appropriate class. See:

	>> a = 7;
	>> b = 'some string';
	>> whos
	Name Size Bytes Class
	a    1x1   8    double
	b    1x11 22    char

The command `whos` display the class of each value in the workspace. Here, Matlab recognized that `7` should be a *double* and `some string` a *char*, ie a string. 
So now, let’s see what happens if you type `a+2`. Matlab will recognize that you try to perform an addition of two instances of class *double* and then look in the list of available functions for this class (we call them methods) for the method `plus.m` corresponding to the special operator `+`. It will pass the two instances (`a` and `2`) as arguments to `plus.m` which will return a new instance of class *double* with the value `9`. 
Note that if you try `a+b`, it will throw an error because the method `plus.m` of the class *double* doesn’t know what to do with a object of class `char`.

We can go even further, because if you type `a+2` at the command window without adding a semi-colon at the end of the line, then Matlab will also call for the method `display.m` from the class *double* in order to know how to print `9` in the command window.

So basically, every time you do something in a script or type in the command window, Matlab reduces it to the identification of classes of the objects and calls of the appropriate methods.

The magic is that Matlab lets us create our own classes. This means that we can manipulate and work with objects from which we’ll be able to control all the behaviors. In **COPODA**, we have 3 main classes: **odata**, **transect** and **database**. 

The class **odata** (for Object Data) is the core object to hold measurements and their meta data, like units. But why do we need meta data attached to a simple array of values ? Because it allows for a safe manipulation of data. Imagine that you compare and work with measurements of a similar variable but from two different sensors, oxygen for instance. You have two matrices of the same size, with values of class `double`. If you take the mean of them you will have no guaranty that you used two arrays with the same oxygen unit. What if one sensor provides oxygen in `mumol/kg` and the other in `ml/l` ? You won’t have any error from Matlab to tell you it’s a bad result. The class **odata** is precisely built to avoid such mistakes. If you try to add two **odata** objects, the `plus.m` method from the class will check for the unit of each object and throw an error if they are different.

Matlab uses the following vocabulary to describe different parts of a class definition and the related concepts:

* Class definition — Description of what is common to every instance of a class.
* Properties — Data storage for class instances
* Methods — Special functions that implement operations that are usually performed only on instances of the class
* Objects — Instances of classes, which contain actual data values stored in the objects' properties
* Packages — Folders that define a scope for class and function naming

These are general descriptions of these components and concepts. The [online documentation][link-matlabclass] describes all of these components and more in detail.

Last, note that a class instance can be created with two different ways of calling the class constructor.
A call with no argument will create the object with default properties:
	
	>> T = transect;

A call with pairs of properties/properties-values will fill specified fields:
	
	>> T = transect('creator','John Doe');


Object Data: the odata matlab class
===================================

The **odata** class implements numerical arrays with meta data into the Matlab workspace. 
It extends the manipulation of documented data and manipulation of variables are safer (through units consistence checking for instance). 
Note that it is independent of the other classes of the **COPODA** framework. 

List of properties
------------------

The **odata** class implements objects with the following properties:

Property | Matlab native class | Description | Default | Example
--- | --- | --- | --- | ---
name | char | A short name of the variable | *empty string* | 'TEMP'
unit | char | A short string to indicate the unit of the variable | *empty string* | 'degC'
long_name | char | A long name of the variable | *empty string* | 'Temperature'
long_unit | char | A long string to indicate the unit of the variable | *empty string* | 'degree Celsius'
cont | double | The values of the variable. This is where the data are stored. | NaN | [17.12 18.56]

**Rq**: More properties are slowly implemented and may appear in the following displays of **odata** object content. But if they are not in the above table, they are not supported.

Creating **odata** objects
--------------------------

Let’s use the Matlab `wind` data to create two **odata** objects with zonal and meridional velocity components:

	load wind
	D1 = odata;
	D1.name = 'U';
	D1.long_name = 'Zonal velocity';
	D1.unit = 'm/s';
	D1.cont = u;

Here, we first created the default **odata** object D1, then we assigned its properties. We can then, check at the D1 structure and content:

	>> whos D1
	  Name       Size                Bytes  Class    Attributes
	  D1        35x41x15            173652  odata     
	>> D1
	  name (unit): U (m/s)
	         size: 35 x 41 x 15
	        stats: max=78.213280, min=-13.718123, mean=17.331760, std=14.822548         

Another method to create **odata** object is to directly assign properties:

	>> D2 = odata('long_name','Meridional velocity','name','V','unit','m/s','cont',v)
	name (unit): V (m/s)
	       size: 35 x 41 x 15
	      stats: max=43.740044, min=-47.391464, mean=-0.598801, std=11.223342

In the command window, the display of an **odata** object is very specific. It provides you with a synthetic set of information about the object, like name and units but also statistics of the content. For a more detailed outlook of the object, you can use the `more` method:

	>> more(D1)
	OData object content description =======================================================
	         Long Name [short]: Zonal velocity [U]
	         Long Unit [short]:  [m/s]
	         	          Size: 35 x 41 x 15
	        Content statistics: Max=78.213280, Min=-13.718123, Mean=17.331760, STD=14.822548
	                 Precision: Max=NaN, Min=NaN
	                Dimensions: undefined in the base workspace
	========================================================================================


Reading and writing content
---------------------------

You can access the content of an **odata** object property using an object oriented syntax like (note the different indexing methods):

	D1.cont(1,:,1:end-1)
	D1.long_name(1:end)

You can modified the content of a property in the same way:

	D1.cont(1,:,1) = 12
	D1.long_name(end-1) = 'Z'

As the numerical content is known to be in the `cont` property, the following shorter syntax is also possible:

	>> D1(1,:,1:end-1)
	>> D1(1,:,:) = 12;

For all the other properties (`name`, `unit`, `long_name` and `long_unit`), use the object oriented syntax. For instance:

	>> D1.long_name
	ans =
	Zonal velocity

	>> D1.long_name(1:3)
	ans =
	Zon

And if you want to extract the entire numerical content, you can finally use the method `cont`:

	cont(D1)





Reference
=========

[copoda-scheme]: ./images/DocCOPODA.png "Schematic of COPODA"
[link-matlabclass]: http://www.mathworks.fr/fr/help/matlab/matlab_oop/classes-in-the-matlab-language.html?s_tid=doc_12b  "Matlab help on clases"
