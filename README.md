The purpose of this workspace is to demonstrate how to obtain itemized information on costs incurred in AnVIL usage.

Command `browse_reck2()` can be used to produce a table like:

![table](https://storage.googleapis.com/bioc-anvil-images/billTab-721.png)

We can also see dynamic itemization over time:

![Figure](https://storage.googleapis.com/bioc-anvil-images/billImg0721.png)

Follow the instructions in [Google's documentation on BigQuery exports of billing information](https://cloud.google.com/billing/docs/how-to/export-data-bigquery).

Once the BigQuery project and dataset are established and are receiving expense data, you can use `browse_reck2()` in AnVIL after installing the AnVILBilling package.

You will have to be authenticated to BigQuery, and will see a request in the console as you start using the app:

![auth](https://storage.googleapis.com/bioc-anvil-images/authshot.png)
