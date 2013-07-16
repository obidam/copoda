Object Data: the odata matlab class
===================================

The **odata** class implements numerical arrays with meta data into the Matlab workspace. 
It extends the manipulation of documented data and  manipulation of variables are safer (through units consistence checking for instance). 
Note that it is independent of the other classes of the COPODA framework. 

List of properties
------------------

The **odata** class implements objects with the following properties:

Property | Matlab native class | Description | Default | Example
--- | --- | --- | --- | ---
name | char | A short name of the variable | *empty string* | “TEMP”		
unit | char | A short string to indicate the unit of the variable | *empty string* | “degC”
long_name | char | A long name of the variable | *empty string* | “Temperature”
long_unit | char | A long string to indicate the unit of the variable | *empty string* | “degree Celsius”
cont | double | The values of the variable. This is where the data are stored. | NaN | 
	
**Rq**: More properties are slowly implemented and may appear in the following displays of **odata** object content. But if they are not in the above table, they are not supported.

Creating **odata** objects
--------------------------

Let’s use the Matlab “wind” matrix to create two **odata** objects with zonal and meridional velocity components:

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

In the command window, the display of an **odata** object is very specific. It provides you with a synthetic set of information about the object, like name and units but also statistics of the content. For a more detailled outlook of the object, you can use the `more` methode:

	>> more(D1)
	OData object content description =======================================================
	         Long Name [short]: Zonal velocity [U]
	         Long Unit [short]:  [m/s]
	         	          Size: 35 x 41 x 15
	        Content statistics: Max=78.213280, Min=-13.718123, Mean=17.331760, STD=14.822548
	                 Precision: Max=NaN, Min=NaN
	                Dimensions: undefined in the base workspace
	========================================================================================

Accessing and modifying content
-------------------------------

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
	

Mathematical operations of **odata** objects
--------------------------------------------

As long as units are compatible, two or more **odata** objects can be multiplied, divided, added and subtracted. If units are not compatible, an error will be thrown. For instance, using the objects D1 and D2 created in the example above, which both have a velocity unit, we can't take the sum of one field with the square of the second:

	>> D1 + D2.^2
	Error using odata/plus (line 63)
	Cannot compute sum of 2 odata objects with different units !
	[m/s] versus [(m/s)^{2}]

If units are compatible, the new object will have a smart guess of the names and units: 

	>> D1+D2
	OData object content description =======================================================
	         Long Name [short]: (Zonal velocity + Meridional velocity) [(U + V)]
	         Long Unit [short]:  [m/s]
	        Content statistics: Max=96.823258, Min=-22.234196, Mean=16.732959, STD=17.377136
	                 Precision: Max=NaN, Min=NaN
	                      Size: 35 x 41 x 15
	                Dimensions: undefined in the base workspace
	========================================================================================	
	>> D1-D2
	OData object content description =======================================================
	         Long Name [short]: (Zonal velocity - Meridional velocity) [(U - V)]
	         Long Unit [short]:  [m/s]
	        Content statistics: Max=90.269748, Min=-24.399337, Mean=17.930562, STD=19.732659
	                 Precision: Max=NaN, Min=NaN
	                      Size: 35 x 41 x 15
	                Dimensions: undefined in the base workspace
	========================================================================================	
	>> D1.*D2
	OData object content description =======================================================
	         Long Name [short]: (Zonal velocity * Meridional velocity) [(U * V)]
	         Long Unit [short]:  [(m/s)^2]
	        Content statistics: Max=1927.976459, Min=-2037.133272, Mean=-32.230508, STD=356.115237
	                 Precision: Max=NaN, Min=NaN
	                      Size: 35 x 41 x 15
	                Dimensions: undefined in the base workspace
	========================================================================================	
	>> D1./D2
	OData object content description =======================================================
	         Long Name [short]: (Zonal velocity / Meridional velocity) [(U / V)]
	         Long Unit [short]:  []
	        Content statistics: Max=270.828389, Min=-814.125757, Mean=-1.584107, STD=26.144253
	                 Precision: Max=NaN, Min=NaN
	                      Size: 35 x 41 x 15
	                Dimensions: undefined in the base workspace
	========================================================================================

New names and units will also work with more complex operations:

	>> 2.*D1+D2+D1
	OData object content description =======================================================
	         Long Name [short]: ((n*Zonal velocity + Meridional velocity) + Zonal velocity) [((n*U + V) + U)]
	         Long Unit [short]:  [m/s]
	        Content statistics: Max=247.903534, Min=-36.790755, Mean=51.396479, STD=44.409632
	                 Precision: Max=NaN, Min=NaN
	                      Size: 35 x 41 x 15
	                Dimensions: undefined in the base workspace
	========================================================================================
	>> D1.^2 + D2.^2
	OData object content description =======================================================
	         Long Name [short]: (Zonal velocity^{2} + Meridional velocity^{2}) [(U^{2} + V^{2})]
	         Long Unit [short]:  [(m/s)^{2}]
	        Content statistics: Max=6226.352407, Min=0.071885, Mean=646.403767, STD=833.449476
	                 Precision: Max=NaN, Min=NaN
	                      Size: 35 x 41 x 15
	                Dimensions: undefined in the base workspace
	========================================================================================

Note that operations work up to a certain level of complexity. The following example should return a valid result but throws an error:

	>> D1 + (D2.^2).^(1/2)   
	Error using odata/plus (line 63)
	Cannot compute sum of 2 odata objects with different units !
	[m/s] versus [((m/s)^{2})^n]


Manipulation of **odata** object
--------------------------------

### Modifying the numerical content

As long as only one **odata** object is involved in a mathematical operation, units checking are not enforced. 

**It is possible to modify the numerical content as a whole**. For instance, the following operations are possible:

	D1 + 2
	D1 .* 2
	D1 +  ones(size(D1))
	D1 .* ones(size(D1))

Doing so, directly modify and apply to numerical values of the "cont" property of the **odata** object.

However, **modifying only a subset of the numerical values is not possible.** The following examples will throw errors:

D1(

Complex
-------

	>> abs(complex(D1,D2))
	OData object content description =======================================================
	         Long Name [short]: abs(Zonal velocity + i*Meridional velocity) [abs(U + i*V)]
	         Long Unit [short]:  []
	        Content statistics: Max=78.907239, Min=0.268115, Mean=20.598195, STD=14.903974
	                 Precision: Max=NaN, Min=NaN
	                      Size: 35 x 41 x 15
	                Dimensions: undefined in the base workspace
	========================================================================================
	>> sqrt(D1.^2+D2.^2)
	OData object content description =======================================================
	         Long Name [short]: sqrt((Zonal velocity^{2} + Meridional velocity^{2})) [sqrt((U^{2} + V^{2}))]
	         Long Unit [short]:  []
	        Content statistics: Max=78.907239, Min=0.268115, Mean=20.598195, STD=14.903974
	                 Precision: Max=NaN, Min=NaN
	                      Size: 35 x 41 x 15
	                Dimensions: undefined in the base workspace
	========================================================================================

Visualization
-------------
