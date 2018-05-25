
# starpeace-website-client

[![Build Status](https://travis-ci.org/ronappleton/starpeace-website-client.svg)](https://travis-ci.org/ronappleton/starpeace-website-client)

Client website for [Starpeace](https://www.starpeace.io), including webgl game client, client-side gameplay logic, and user interface controls.

## Official Documentation

Documentation for client gameplay can be found on the [Starpeace website](https://www.starpeace.io/docs).

## Roadmap

Development and gameplay roadmap can be found on the [Starpeace Community Development website](https://www.starpeace.ovh/).

## Security Vulnerabilities

If you discover a security vulnerability within Starpeace website, please send an e-mail to admin@starpeace.ovh or open a [GitHub issue](https://github.com/ronappleton/starpeace-website-client/issues). All security vulnerabilities will be promptly addressed.

## Development

Local development can be accomplished in a few commands. The following build-time dependencies must be installed:

* [Node.js](https://nodejs.org/en/) javascript runtime and [npm](https://www.npmjs.com/get-npm) package manager
* [Grunt](https://gruntjs.com/) task manager

Retrieve copy of repository and navigate to root:

```
$ git clone https://github.com/ronappleton/starpeace-website-client.git
$ cd starpeace-website-client
```

Install starpeace-website-client dependencies:

```
$ npm install
```

Build repository with default or ```build``` grunt target:

```
$ grunt
$ grunt build
```

To simplify and improve development, the ```watch``` grunt target can be executed to watch for file changes and automatically rebuild application:

```
$ grunt watch
```

A simple server is also provided to serve static assets for local testing, accessible at [127.0.0.1:11010](http://127.0.0.1:11010) using ```server``` grunt target:

```
$ grunt server
```

## Build and Deployment

After building repository, website is compiled into static resources within the ```/build/public/``` folder. These resources should be served as static assets from web application and can be cached if desired.

## License

Starpeace website is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
