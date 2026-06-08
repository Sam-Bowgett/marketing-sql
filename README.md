# marketing-sql
SQL marketing analytics project

Business problem
- A retail bank runs email and SMS campaigns promoting credit cards, personal loans, term deposits, and home loan refinancing. The marketing analytics team needs to identify which customer segments are most likely to convert, and which campaign channels and offers are driving the most profitable acquisitions — so that future marketing spend can be allocated to the highest-ROI opportunities.

Tools Used:
- PostgreSQL — Database management system where I built and stored the data.
- PGAdmin — Interface I used to write and run SQL queries.
- Mockaroo — Generated the synthetic data.

Database Schema
- customers — contains information on 1000 bank customers including region, age and income bracket.
- products — contains 4 bank products being promoted across campaigns.
- campaigns — contains 20 marketing campaigns including channel, cost and dates.
- campaign_contacts — records which customers were contacted by which campaign and their how they engaged with the campaignes such as opened, clicked, responded.
- conversions — records the successful outcomes where a customer used a bank product from a marketing campaign, including the revenue generated.

Key Findings
- Refinance Campaign was the best performer — generating $290k in total revenue, almost double what the next best campaign did.
- Personal Loan had the highest total revenue across all products at $160k. This made it the bank's most profitable campaign product.
- Term Deposit generated the highest average revenue per conversion at $3,042 — meaning when customers do take it out, it's worth the most to the bank.
- QLD customers in the low income bracket generated the highest average revenue of any segment at $3,335. This suggests low income customers in QLD may be taking out higher value products than expected.

Data Limitations
- All of the data in this project was generated using Mockaroo and doesn't corrently represent real customer or campaign data.
- Because customer IDs and campaign IDs were randomly generated independently across tables, some of the queries produced unrealistic results such as 100% conversion rates — in real data these relationships would be more controlled.
- Campaign names were limited to 4 unique values across 20 campaigns, which meant some of the analysis grouped distinct campaigns together.
- With only 200 conversion records the dataset is relatively small where real data would have thousands of conversions producing better and more varied results.
