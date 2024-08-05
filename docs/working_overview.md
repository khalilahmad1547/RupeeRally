# Dry test scenarios
 - ## Add individual user income
	User ***U*** add an income of amount ***amount_cents*** to account ***account*** selecting income category ***category*** and adding description ***description***.
	- create a ***transaction*** in **Transaction** table with
		**description** 	= ***description***
		**created_by** = ***U[id]***
		**amount_cents** = ***amount_cents***
		**divided_by** = ***none***
	- create a ***user_transaction*** in **User Transaction** table with
		**description** 	= ***description***
		**user_id** = ***U[id]***
		**account_id** = ***account[id]***
		**category_id** = ***category[id]***
		**transaction_type** = ***income***
		**user_share** = ***nil*** (need to think to keep data validating each other)
		**amount_cents** = ***amount_cents***

- ## Add individual user expense
	User ***U*** add an expense of amount ***amount_cents*** from account ***account*** selecting expense category ***category*** and adding description ***description***.
	- create a ***transaction*** in **Transaction** table with
		**description** 	= ***description***
		**created_by** = ***U[id]***
		**amount_cents** = ***amount_cents***
		**divided_by** = ***none***
	- create a ***user_transaction*** in **User Transaction** table with
		**description** 	= ***description***
		**user_id** = ***U[id]***
		**account_id** = ***account[id]***
		**category_id** = ***category[id]***
		**transaction_type** = ***expense***
		**user_share** = ***1*** (need to think to keep data validating each other)
		**amount_cents** = ***amount_cents***
		**paid_by** = ***U1[id]***

- ## Add shared expense
	User ***U1*** add an expense of amount ***amount_cents*** from account ***account*** equally divided by users ***U2***, ***U3*** by selecting expense category ***category*** and adding description ***description***.
	- create a ***transaction*** in **Transaction** table with
		**description** 	= ***description***
		**created_by** = ***U1[id]***
		**amount_cents** = ***amount_cents***
		**divided_by** = ***equally***
	- create a ***u1_user_transaction_01*** in **User Transaction** table for ***U1***  expense with
		**description** 	= ***description***
		**user_id** = ***U1[id]***
		**account_id** = ***account[id]***
		**category_id** = ***category[id]***
		**transaction_type** = ***expense***
		**user_share** = ***1*** (need to think to keep data validating each other)
		**amount_cents** = ***amount_cents/3***
		**paid_by** = ***U1[id]***
		
	- create a ***u2_user_transaction_02*** in **User Transaction** table for user  ***U2*** expense with
		**description** 	= ***description***
		**user_id** = ***U2[id]***
		**account_id** = ***nil***
		**category_id** = ***nil***
		**transaction_type** = ***expense***
		**user_share** = ***1*** (need to think to keep data validating each other)
		**amount_cents** = ***amount_cents/3***
		**paid_by** = ***U1[id]***
	
	- create a ***u2_user_transaction_02*** in **User Transaction** table for user  ***U3*** expense with
		**description** 	= ***description***
		**user_id** = ***U3[id]***
		**account_id** = ***nil***
		**category_id** = ***nil***
		**transaction_type** = ***expense***
		**user_share** = ***1*** (need to think to keep data validating each other)
		**amount_cents** = ***amount_cents/3***
		**paid_by** = ***U1[id]***
	
	### Algorithm
	- given **current_user** = ***U1***
	- get required info
	**amount_cents** = ***amount_cents***
	**description** = ***description***
	**divide_on** = ***[user_id_01, user_id_02]*** (list of user ids on which this expense is to be divided).
	**paid_by** = ***U1[id]*** (user id)
	**division_method** = ***equally*** (possible values enum(none, equally, percent, shares, unequally))
	**user_share** = ***{user_id_01:  1, user_id_02: 1}***
	- IF **division_method** === ***equally***
		- **number_of_users** = ***divide_on.length***
		- **user_share** = ***amount_cents/number_of_users***
		- FOR ***user_id*** in ***divide_on***
			- user_transaction({
				**description**: *description*,
				**user_id**: *user_id*,
				**account_id**: *nil*,
				**category_id**: *nil*,
				
			 })
	
