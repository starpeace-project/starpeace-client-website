
# starpeace-client-website

[![GitHub release](https://img.shields.io/github/release/starpeace-project/starpeace-client-website.svg)](https://github.com/starpeace-project/starpeace-client-website/releases/)
[![GitHub license](https://img.shields.io/github/license/starpeace-project/starpeace-client-website.svg)](https://github.com/starpeace-project/starpeace-client-website/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/starpeace-project/starpeace-client-website.svg)](https://github.com/starpeace-project/starpeace-client-website/issues)
[![GitHub stars](https://img.shields.io/github/stars/starpeace-project/starpeace-client-website.svg)](https://github.com/starpeace-project/starpeace-client-website/stargazers)
[![Discord](https://img.shields.io/discord/449310464321650703.svg?logo=discord)](https://discord.gg/TF9Bmsj)

Client website for [STARPEACE](https://www.starpeace.io), including webgl rendering client, client-side javascript and AJAX gameplay logic, and HTML5 user interface controls. https://client.starpeace.io

## Official Documentation

Documentation for client gameplay can be found on the [STARPEACE documentation website](https://docs.starpeace.io).

## Roadmap

Active development and gameplay roadmap can be [found in RELEASE.md](./RELEASE.md), historical changelog can be [found in RELEASE-archive.md](./RELEASE-archive.md), and a rough plan for anticipated next steps can be [found in ROADMAP.md](./ROADMAP.md).

Current release notes are also [available in client](https://client.starpeace.io/release) at https://client.starpeace.io/release

## Security Vulnerabilities

If you discover a security vulnerability within the STARPEACE website, please send an e-mail to security@starpeace.io or open a [GitHub issue](https://github.com/starpeace-project/starpeace-client-website/issues). All security vulnerabilities will be promptly addressed.

## Contributing

starpeace-client-website welcomes all contributions: development, game design, translations, or play-testing; please let us know if you'd like to get involved! Please [join Discord chatroom](https://discord.gg/TF9Bmsj) and [read the contributing guide](./CONTRIBUTING.md) to learn more.

## Build and Deployment

After building repository, website is compiled into static resources within the ```/dist/``` folder. These resources should be served as static assets from web application and can be cached if desired.

### client.starpeace.io

Repository is currently deployed to and hosted with AWS S3 and CloudFront. Changes pushed to repository will activate webhook to AWS CodePipeline, triggering automatic rebuild and deployment of website resources.

## License

starpeace-client-website is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
