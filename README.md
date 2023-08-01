# sec-eng-challenge

Challenge Project//

## Instructions
Deploy the application either locally, containerized via docker, or in a local minikube cluster. More information can be found using:
```
./start.sh -h
```

For both local and containerized, the application runs on `localhost:3000`.

Files can be uploaded with using form-data as follows, a password is optional:
```
curl -X POST 'localhost:3000/upload' --form 'password="YOURPASSWORD"' --form 'file=@"</FILEPATH>"'

```

Files can be retrieved by providing the password, if needed:
```
curl 'localhost:80/download/<FILENAME>?password=YOURPASSWORD'
```

The `start.sh` script sets up automatically the minikube environment, the exposed URL for the same operations above is ``.


## Todo
* Implement a basic front-end
* Refactor file/folder structure
* Add tests / improve test coverage
* CI with Github Actions for testing with jest, building and pushing to DockerHub registry
* Implement IaC using Terraform for GCP in addition with files 

