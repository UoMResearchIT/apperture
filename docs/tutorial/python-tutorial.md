# Python Tutorial

This document will walk you through obtaining and running the smalldata Python client.

You will need:
- An account on a smalldata instance (ask an admin if you don't have one!)
- A working python installation

You should have:
- A virtual environment (to isolate the smalldata client from your wider system)

## Getting started

The first thing we must do is obtain the smalldata client packages using pip (Conda support is planned).

```console
pip install -i https://test.pypi.org/simple/ smalldataio 
```

## First steps in smalldata

Now we have the client, we are ready to connect!

_A small note: we will use Python interactively in this tutorial, but it is more typical to use smalldata in a scripted manner._

Let's start Python and import smalldata:

```console
# This should be written in your bash terminal
python

# This one in Python
>>> import smalldata_io_python
```

If this works, we are ready to go!

## Connect to smalldata

### Connecting

For the first step, we will need to know the URL we are connecting to. 

There is a reference smalldata instance at https://smalldata.oms-lab.org/ but you will need to ask your Admin what the corrent instance URL is.

This URL should be substituted into the connect command below

```python
>>> from smalldata_io_python.client import Smalldata
>>> client = Smalldata('smalldata.oms-lab.org')
```

Hopefully, you will see output like the following, if so: you have connected successfully!

```python
DEBUG [client.py.__init__:127] Connect to smalldata.oms-lab.org
```

### Getting more user info

Now we've connected, why don't we find out a bit more about your user?

```python
>>> client.get_user_info()
```
Oh no! An error! Sorry for the trick, but this shows you what will happen if you are not authenticated to smalldata. If you see errors like this, you should make sure you are signed in and your session (cookie) is up to date.

```python
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/owool/.local/lib/python3.11/site-packages/smalldata_io_python/client.py", line 152, in verify_auth_wrapper
    raise UnauthorizedError('Not authorized')
smalldata_io_python.exc.UnauthorizedError: Not authorized
```

### Signing in (Authenticating)

So how do we sign in? With the following command:

```python
>>> client.connect(your_username, your_password)
```

Now you should see much happier output, something like:

```python
INFO [client.py.connect:180] Attempting authentication for user your_username
WARNING [client.py.connect:190] No cached session found, please authenticate
INFO [client.py.connect:226] Authenticating via https://authelia.smalldata.oms-lab.org
DEBUG [client.py.connect:229] Authentication attempt responds <Response [200]>
DEBUG [client.py.get_username:305] {'status': 'OK', 'data': {'username': 'your_username', 'authentication_level': 1, 'default_redirection_url': 'https://api.smalldata.oms-lab.org'}}
```

### Really getting more user info

Now we are signed in, we actually can find out some more about ourselves:

```python
>>> res = client.get_user_info()
>>> res.content
```

Which should show some additonal parameters:

```python
b'{"status":"OK","data":{"display_name":"","method":"totp","has_totp":false,"has_webauthn":false,"has_duo":false}}'
```

## Managing and creating tables

Now we have connected and signed in, we can start commiting data to the smalldata database!

### Listing tables

First, let's check which tables we own:

```python
>>> tables = client.list_tables()
>>> print(tables)
[]
```

You probably don't have any tables! In which case you should just see an empty list as above.

### Creating tables

Let's set about changing that.

```python
>> > new_table = client.create_table(table_name="My first table!")
DEBUG[client.py.create_table:337]
User
my_user: create
table
My
first
table! with metadata {}
```

You can check the new table has been created using list_tables again:

```python
>>> tables = client.list_tables()
>>> print(tables)
[SmalldataTable(name=My first table!, id=8)]
```

### Creating tables with metadata

It is also posible to add in pieces of metadata when creating a table.

This is also achieved using the create_table command, but this time with an additional option:

```python
>> > meta_table = client.create_table(table_name="My meta table!", meta={"Now": "With", "Some": "Metadata!"})
DEBUG[client.py.create_table:337]
User
my_user: create
table
My
meta
table! with metadata {'Now': 'With', 'Some': 'Metadata!'}
```

Listing again:

```python
>>> tables = client.list_tables()
>>> print(tables)
[SmalldataTable(name=My first table!, id=8), SmalldataTable(name=My meta table!, id=9)]
```

## Adding and getting data

So what is in the tables we created? Let's pick one!

### Getting table

First let's double check which tables we own:

```python
>>> tables = client.list_tables()
>>> print(tables)
[SmalldataTable(name=My first table!, id=8), SmalldataTable(name=My meta table!, id=9)]
```

We can get a table directly from this list (e.g. `table = tables[0]`), or we can use another smalldata method. get_table lets us get a table using its id.

```python
>>> table = client.get_table(9) # n.b. substitute the id of a table you own here!
DEBUG [client.py.get_table:663] Getting table with ID 9
>>> print(table)
SmalldataTable(name=My first table!, id=9)
```

What can we do with this table object?

### Getting info

Let's check on the table's information:

```python
>>> table.name
'My meta table!'
>>> table.meta
{'Now': 'With', 'Some': 'Metadata!'}
>>> table.id
9
```

This parameters may be exactly what we expect, but they can be useful!

### Getting contents

Now we are getting more familiar with the table object - shall we find out what is inside? 

There are two major methods for this, one available to any smalldata user, and another available only to Python users which we will show off later on.

Starting with the general smalldata method, we first need to decent to column level. We'll start by listing the columns:

```python
>>> table.list_columns()
DEBUG [client.py.list_columns:736] Listing Columns with table_id=9
[]
```

### Adding columns

Unsurprisingly, our new table has no columns! Let's change that:

```python
>>> col = table.add_column("a first column")
DEBUG [client.py.add_column:385] Add column a first column with metadata {} to table 9
>>> print(col)
SmalldataColumn(name=a first column, id=10)
>>> table.list_columns()
DEBUG [client.py.list_columns:736] Listing Columns with table_id=9
[SmalldataColumn(name=a first column, id=10)]
```

Great! Now we've got a column, let's see what's in it:

```python
>>> col.get_points()
DEBUG [client.py.retrieve_column:632] Retrieving all data from column 10
[]
```

### Adding points

Ah yes, empty again! So, again, let's address that!

```python
>>> point = col.add_point(data="Lovely data")
DEBUG [client.py.store:460] Storing a payload with metadata {} to column 10
>>> print(point)
SmalldataPoint(id=28)
>>> print(point.value())
Lovely data
>>> col.get_points()
DEBUG [client.py.retrieve_column:632] Retrieving all data from column 10
[SmalldataPoint(id=28)]
>>> 
```

### Summary

Great! So we have now gone the whole way through the smalldata heirachy. We have:
- Created a table
- Added columns
- Added data
- Retreived all of these

Everything you need to get started using smalldata!

## Automating

You might be wondering how you might apply all of this! The point of smalldata is how it allows you to make high frequency, automated additions to tables.

Let's apply this idea by creating a script:

```python
## My wonderful, and very real, experiment submitting data from my kit to smalldata, in real time
## The experiment is probing a sample, moving in a linear line and taking a measurement at each grid point
## We will then do some very complex post processing

import time  # we'll use this for a time stamp
import random  # and this for the "very real" data

# ------------------------------------------------------------------------
# First let's create a table
my_experiment = client.create_table(table_name="My experiment", meta={"Timestamp": time.time_ns()})

# ------------------------------------------------------------------------
# Gathering data
experiment_data = my_experiment.add_column("Raw data")

# Iterate over linear line
for ii in range(1, 10):
    # Take measurement
    mes = random.random()

    # Push measurement
    experiment_data.add_point(data=mes)

# ------------------------------------------------------------------------
# Post processing
processed_data = my_experiment.add_column("Processed data")

# Iterate over raw data
for point in experiment_data.get_points():
    # Do the post processing
    proc = point.value() * 100

    # Push the outcome
    processed_data.add_point(data=proc)
```

Lovely! We've ~~generated~~ _measured_ some data and recorded it! But do we need to write another script to access it?

Actually, this is where the Python method we mentioned earlier comes in: we can dump the smalldata table straight into a Pandas dataframe!

```python
>>> my_experiment.to_pandas()
DEBUG [client.py.list_columns:736] Listing Columns with table_id=10
DEBUG [client.py.retrieve_column:632] Retrieving all data from column 11
DEBUG [client.py.retrieve_column:632] Retrieving all data from column 12
    Raw data  Processed data
29  0.607193             NaN
30  0.379480             NaN
31  0.291377             NaN
32  0.550353             NaN
33  0.929357             NaN
34  0.097690             NaN
35  0.597384             NaN
36  0.547407             NaN
37  0.482924             NaN
38       NaN       60.719282
39       NaN       37.947972
40       NaN       29.137708
41       NaN       55.035267
42       NaN       92.935749
43       NaN        9.768964
44       NaN       59.738379
45       NaN       54.740710
46       NaN       48.292429
```

Now, you might find this output to look a little strange, why is my data not arranged in rows alonside the raw data? This is actually a feature of smalldata (not a bug!) and it's important to note that, by default, added points are not associated with data in other columns!

However, we can make our script behave more like you might expect, by associating inserted data with previous values. This requires a small change to our script above:

```python
# ------------------------------------------------------------------------
# Post processing (append)
processed_data_append = my_experiment.add_column("Processed data (append)")

# Iterate over raw data
for point in experiment_data.get_points():
  # Do the post processing
  proc = point.value() * 100

  # Push the outcome
  processed_data_append.add_point(data=proc, row=point.row)
```

Let's check on this:

```python
>>> my_experiment.to_pandas()
DEBUG [client.py.list_columns:736] Listing Columns with table_id=10
DEBUG [client.py.retrieve_column:632] Retrieving all data from column 11
DEBUG [client.py.retrieve_column:632] Retrieving all data from column 12
DEBUG [client.py.retrieve_column:632] Retrieving all data from column 13
    Raw data  Processed data  Processed data (append)
29  0.607193             NaN                60.719282
30  0.379480             NaN                37.947972
31  0.291377             NaN                29.137708
32  0.550353             NaN                55.035267
33  0.929357             NaN                92.935749
34  0.097690             NaN                 9.768964
35  0.597384             NaN                59.738379
36  0.547407             NaN                54.740710
37  0.482924             NaN                48.292429
38       NaN       60.719282                      NaN
39       NaN       37.947972                      NaN
40       NaN       29.137708                      NaN
41       NaN       55.035267                      NaN
42       NaN       92.935749                      NaN
43       NaN        9.768964                      NaN
44       NaN       59.738379                      NaN
45       NaN       54.740710                      NaN
46       NaN       48.292429                      NaN
```

You can see the append column is now associated with the original data values.

## Sharing with another user (modifying access)

Of course, you will probably want to share this stunning data with others, this is possible within smalldata.

To achieve this, you can add an access rule, let's say we want to let (fellow smalldata) user "supervisor", read your data.

```python
>>> client.administer_access_table(my_experiment, "supervisor", "GETTER")
DEBUG [client.py.administer_access_table:532] CLIENT: Administering access for user supervisor to table {table.id} with level {level}
```

They can now read your table! It is also possible to grant people the ability to insert data, and to make new columsn - or even apoint them co-owners!

## Ending the session

This brings us to the end of this tutorial, the last thing to do is to close the smalldata session:

```python
>>> client.logout()
INFO [client.py.logout:261] Removing session cookie
True
```
