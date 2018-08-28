
# starpeace-website-client

[![GitHub release](https://img.shields.io/github/release/starpeace-project/starpeace-website-client.svg)](https://github.com/starpeace-project/starpeace-website-client/releases/)
[![Build Status](https://travis-ci.org/starpeace-project/starpeace-website-client.svg)](https://travis-ci.org/starpeace-project/starpeace-website-client)
[![GitHub license](https://img.shields.io/github/license/starpeace-project/starpeace-website-client.svg)](https://github.com/starpeace-project/starpeace-website-client/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/starpeace-project/starpeace-website-client.svg)](https://github.com/starpeace-project/starpeace-website-client/issues)
[![GitHub stars](https://img.shields.io/github/stars/starpeace-project/starpeace-website-client.svg)](https://github.com/starpeace-project/starpeace-website-client/stargazers)
[![Discord](https://img.shields.io/discord/449310464321650703.svg)](https://discord.gg/TF9Bmsj)
![Twitter Follow](https://img.shields.io/twitter/follow/starpeace_io.svg?style=social&label=Follow)

Client website for [STARPEACE](https://www.starpeace.io), including webgl game client, client-side gameplay logic, and user interface controls. https://client.starpeace.io

## Official Documentation

Documentation for client gameplay can be found on the [STARPEACE documentation website](https://docs.starpeace.io).

## Roadmap

Active development and gameplay roadmap can be [found in RELEASE.md](./RELEASE.md), historical changelog can be [found in RELEASE-archive.md](./RELEASE-archive.md), and a rough plan for anticipated next steps can be [found in ROADMAP.md](./ROADMAP.md). Active and historical release notes are also [available in client](https://client.starpeace.io/release). https://client.starpeace.io/release

## Security Vulnerabilities

If you discover a security vulnerability within the STARPEACE website, please send an e-mail to security@starpeace.io or open a [GitHub issue](https://github.com/starpeace-project/starpeace-website-client/issues). All security vulnerabilities will be promptly addressed.

## Contributing

All contributions to starpeace-website-client are gladly welcome, including any development, translations, or play-testing effort. Please join Discord chatroom or community forums to learn more.

### Development

starpeace-website-client welcomes all developer or designer contributions; please let us know if you'd like to get involved! STAPEACE homepage and license content is located in the [starpeace-website](https://github.com/starpeace-project/starpeace-website) repository, documentation website is located in the [starpeace-website-documentation](https://github.com/starpeace-project/starpeace-website-documentation) repository, and client media assets are located in the [starpeace-website-client-assets](https://github.com/starpeace-project/starpeace-website-client-assets) repository.

Local development can be accomplished in a few commands. The following build-time dependencies must be installed:

* [Node.js](https://nodejs.org/en/) javascript runtime and [npm](https://www.npmjs.com/get-npm) package manager

Retrieve copy of repository and navigate to root:

```
$ git clone https://github.com/starpeace-project/starpeace-website-client.git
$ cd starpeace-website-client
```

Install starpeace-website-client dependencies:

```
$ npm install
```

Build repository with npm command defined in package.json:

```
$ npm run generate
```

Local development with nuxt and interactive build can be started with a single command:

```
$ npm run dev
```

Nuxt webserver is started locally and can be accessed at http://127.0.0.1:11010. Only this specific local URL is whitelisted to retrieve assets from CDN (normally cross-site errors).

### Translations

STARPEACE is a global game with an international player-base, making language translations an important aspect of project. starpeace-website-client aims to support the following languages and is actively looking for any translation contributors:

* English, French, Portuguese, German, Italian, and Spanish

If you'd like to see STARPEACE translated to your native language and can provide translations, please [create an issue](https://github.com/starpeace-project/starpeace-website-client/issues) or [chat with project team](https://discord.gg/TF9Bmsj)!

## Build and Deployment

After building repository, website is compiled into static resources within the ```/dist/``` folder. These resources should be served as static assets from web application and can be cached if desired.

### client.starpeace.io

Repository is currently deployed to and hosted with AWS S3. Changes pushed to repository will activate webhook to AWS CodePipeline, triggering automatic rebuild and deployment of website resources.

## License

starpeace-website-client is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
