# MLOps-Basics

- Reference: [MLOps-Basics](https://github.com/graviraja/MLOps-Basics/tree/main)  

## diff

- dvc storage
  - Google Drive -> AWS S3  
  Although google_api.py can execute, raise error with `dvc push` (can not solve).

```bash
$ dvc push
Collecting                                                                                                       |0.00 [00:00,    ?entry/s]
Pushing
ERROR: unexpected error - unauthorized_client: Client is unauthorized to retrieve access tokens using this method, or client not authorized for any of the scopes requested.

```
