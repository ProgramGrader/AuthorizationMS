# AuthorizationMS

Cerbos AWS Lambda Docker Image
==============================
Gateway service implements AWS Lambda runtime and invokes Cerbos server API hosted in the same AWS Lambda instance.

Cerbos is the open core, language-agnostic, scalable authorization solution that makes user permissions and authorization simple to implement and manage by writing context-aware access control policies for your application resources.

* [Cerbos website](https://cerbos.dev)
* [Cerbos documentation](https://docs.cerbos.dev)
* [Cerbos GitHub repository](https://github.com/cerbos/cerbos)

## Description
This project builds a docker image that can be used to run a Cerbos server in AWS Lambda. The images will contain the gateway executable and the Cerbos binary.

The following commands assume you run a Unix-like system with x86_64 or arm64 architectures.