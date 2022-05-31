# Assignment 7

## Create a web page with the text, images, and links from your Word document.  Since I didn't use images, I'm including an image paste of the entire document at the bottom.

## Name: Aaron Baker (ABaker)
## Date: 5/30/22
## Course: IT FDN 130 A Sp 22: Foundations Of Databases & SQL Programming
## Assignment07_Writeup
## https://github.com/Computant75/DBFoundations

# Assignment 7
# SQL Functions

## Introduction  
	A user defined function in SQL can be very useful for small tasks that you do often.  They can also allow you to create a select statement for a user that just requires one or more variables instead of them having to understand SQL.  Telling a non-technically-minded coworker “Just type myfunction(month) but with the number of the month you want reported” is easy, explaining how to create a select statement with a where clause is not.  Of course, functions can return various outputs.  They can return one item (whether text, integer, date or other), they can return a single line of data (multiple items but all from one row of a table), or they can return a full table.  As such, they can be used where you would otherwise use a single item or a full table.
  
## When to use a SQL User Defined Function (UDF)
	The nice thing about a User Defined Function is that it is permanent (well as permanent as your database).  So if you have to figure out the code to do something, you can do it once and just re-use it.  It can also make your code more compact.  Instead of putting each piece of code for each trick in your view or select statement, you can have simple to read code with your tools performing functions like reformatting a date or combining items.  
	You can also create a function as a report for users who are less skilled.  Instead of forcing them to write an SQL statement, or giving them a pre-written select statement with notes on “change this here to the year you want, and change this to the product you want...” you can write a function that takes year and product ID as inputs and just give them the function.
  
## Differences between Scalar, Inline, and Multi-Statement Functions
	The primary difference between these three types of functions is output.  A Scalar Function returns one item (one field), though it can return a test item, a number, a date, etc.  An Inline Function returns several fields but in one line, for example one line of a view or table.  This can be useful for pulling all data on a customer or a product.  You could build an inline function whose output goes to a program showing that data for easy user viewing.  A Multi-Statement Function returns a table, which can become the input for other views or functions.
	But these differences mean a big difference in how they are used.  You can put a scalar function in the Where clause of a select statement or the Select clause, but you can't put a multi-statement function there because a table wouldn't provide valid input.  I guess you could use a nested select statement inside one of those clauses to pull a single field from a multi-statement function, but that is just a way to convert it to a scalar.  Ultimately, the output determines what you can do with it.  A single field can be used to match an item, or it can be used to format or modify an output.  A table or inline is only going to be used in a join.
  
## Summary  
	You can use a user-defined scalar function to change the way an output appears, or to alter an output.  You can use a user-defined inline function to provide all data on a given line of a table (e.g. all data about a customer, or all data about a product) especially as an output to other programs.  You can use a user-defined multi-statement function to provide a table output, especially to create an easier to use code for other employees.
  
<img src="https://github.com/Computant75/DBFoundations/blob/main/docs/images/Assignment07_Writeup_ABaker-1.png"/>
<img src="https://github.com/Computant75/DBFoundations/blob/main/docs/images/Assignment07_Writeup_ABaker-2.png"/>

Had to use the HTML trick because:

![First page of paper](https://github.com/Computant75/DBFoundations/blob/main/docs/images/Assignment07_Writeup_ABaker-1.png)
![Second page of paper](https://github.com/Computant75/DBFoundations/blob/main/docs/images/Assignment07_Writeup_ABaker-2.png) 

