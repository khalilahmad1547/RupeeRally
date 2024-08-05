# Entities
1. ## **User**
	1. **id**: primary key
	2. **email**: unique per user
	3. **phone_number**: unique per user
	4. **password**: hashed password for user
	5. **provider**: type string, default value is 'email'. it represents user signuped using email, google or other Omni Auth providers.
	6. **avatar_url**: link to profile image

2. ## **Groups**
	1. **id**: primary key
	2. **name**: unique by per created_by
	3. **created_by**: foreign key from user table, user id who created this group.

3. ## **Category**
	1. **id**: primary key.
	2. **name**: unique by per user_id.
	3. **category_type**: enum(income, expense)
	4. **user_id**: foreign key from user table.
	5. ***amount_cents***: total amount got/spent(got if this is an income category & spent if this is expense category) in this category by user

4. ## **Accounts**
	1. **id**: primary key
	2. **name**: unique by per user
	3. **balance_cents**: current balance of this account
	4. **total_income_cents**: total income for this account over a period of time i.e. month
	5. **total_expense_cents**: total expenses for this account over a period of time i.e. month
	6. ***user_id***: foreign key from user table.

5. ## **Transactions**
	1. **id**: primary key
	2. **description**: type text, required.
	3.  **created_by**: user id who created this transaction.
	4. **amount_cents**: total amount user added to create this transaction weather it is individual or shared.
	5. **divided_by**: enum(none, equally, percent, shares, unequally)

6. ## **User Transactions**
	1. **id**: primary key
	2. **description**: type text.
	3. **user_id**: foreign key from user table, owner of user_transaction.
	4. **account_id**: foreign key from Accounts table.
	5. **category_id**: foreign key from Category table.
	6. **transaction_type**: enum(income, expense)
	7. **user_share**: share of user which is divided on it
	8. **amount_cents**: amount which user have as per user_share
	9. ***paid_by***: foreign key from user table, user who paid this amount.
	10. ***transaction_id***:  foreign key from Transaction table, transaction for which this user_transaction is created.
	11. ***status***: enum(pending, settled_up)
