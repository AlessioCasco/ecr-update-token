# ecr-update-token

## Disclaimer

This is a forked version of the original [ecr-update-cred](https://gist.github.com/cablespaghetti/b5343b04dd5bdc68dcb62754986a34ed) from [cablespaghetti](https://gist.github.com/cablespaghetti)

## What we try to solve

If you host docker images in a private registry such as [Amazon Elastic Container Registry](https://aws.amazon.com/ecr/) for kubernetes, chances are you landed on this [kubernetes doc](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) to understand how to pull an image from a private Docker registry or repository.

The problem here is that aws tokens expire after 12 hours, so you need a way to keep them always updated, otherwise you will not be able to pull anything else from the registry once they expire.

This small script creates a cronjob that every 10 hours get a fresh token using aws cli and kubectl.

## Usage

Clone the repo

```bash
git clone git@github.com:AlessioCasco/ecr-update-token.git
```

cd into the project

```bash
cd ecr-update-token
```

run the script with the 5 positional parameters:

```bash
./ecr-secret-creator.sh nginx-ingress ~/.aws/credentials prod-ecr 123456789012 eu-west-1
```

where:

* `nginx-ingress` Is the namespace where everything will be created.
* `~/.aws/credentials` Is the location of your credential file.
* `prod-ecr` Is the profile to use on the credential file.
* `12345678912` Is your aws account.
* `eu-west-1` Is the region where the private registry is located.

This will create under the namespace you defined:

* A secret that holds your aws_access_key_id & aws_secret_access_key.
* A role, a ServiceAccount and a RoleBinding so kubectl within your pod can change and update secrets.
* A CronJob that every 10 hours updates your token. (Since there is no way to run a cronjob as soon as it's created, there is a one-off job for that)

## Notes

Remember that:

* The registry address must exactly match what's in your Pod definition - including the port number
* The secret must be in the same namespace where you are creating your Pod.
* The cronjob expects you have a service account with the same name of the namespace, so it can modify it for use this secret as an imagePullSecret
    This avoids you to declare:

```yaml
 imagePullSecrets:
- name: name_of_the_secret
```

inside every `spec.containers`

## Reference

* [Article about the 12 hours tokens problem](https://medium.com/@xynova/keeping-aws-registry-pull-credentials-fresh-in-kubernetes-2d123f581ca6)
* [kubernetes doc](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
* [Amazon ECR Registries](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html)
* [Original ecr-update-cred](https://gist.github.com/cablespaghetti/b5343b04dd5bdc68dcb62754986a34ed)