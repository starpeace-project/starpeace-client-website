# Contributing to STARPEACE

:+1: Thank you for taking the time to contribute! :+1:

The following is a set of guidelines for contributing to STARPEACE client website and its packages, which are hosted in the [STARPEACE Project Organization](https://github.com/starpeace-project) on GitHub. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

#### Table Of Contents

[Code of Conduct](#code-of-conduct)

[What should I know before I get started?](#what-should-i-know-before-i-get-started)
  * [STARPEACE and Packages](#starpeace-and-packages)
  * [STARPEACE Design Decisions](#design-decisions)

[How Can I Contribute?](#how-can-i-contribute)
  * [Reporting Bugs](#reporting-bugs)
  * [Suggesting Enhancements](#suggesting-enhancements)
  * [Your First Code Contribution](#your-first-code-contribution)
  * [Pull Requests](#pull-requests)
  * [Translations](#translations)

[Styleguides](#styleguides)
  * [Git Commit Messages](#git-commit-messages)
  * [JavaScript Styleguide](#javascript-styleguide)
  * [CoffeeScript Styleguide](#coffeescript-styleguide)
  * [Pug Styleguide](#pug-styleguide)
  * [SASS Styleguide](#sass-styleguide)
  * [Vue and Nuxtjs Styleguide](#vue-and-nuxtjs-styleguide)

## Code of Conduct

This project and everyone participating in it is governed by the [STARPEACE Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [abuse@starpeace.io](mailto:abuse@starpeace.io).

## What should I know before I get started?

Please [join Discord chatroom](https://discord.gg/TF9Bmsj) if you have any questions or would like to learn more about contributing!

### STARPEACE and Packages

STARPEACE Project is made up [several repositories](https://github.com/starpeace-project), each with unique responsibilities.

### Client
* [starpeace-website](https://github.com/starpeace-project/starpeace-website) - static client homepage and license content
* [starpeace-website-client](https://github.com/starpeace-project/starpeace-website-client) - client game application logic and webgl rendering website
* [starpeace-website-client-assets](https://github.com/starpeace-project/starpeace-website-client-assets) - procedural generation and compilation logic of assets for client
* [starpeace-website-documentation](https://github.com/starpeace-project/starpeace-website-documentation) - static and dynamic documentation website

### Server - Universe (identity management and galaxy directory)
* starpeace-server-universe-api - STARPEACE Universe API interface (TBD)

### Server - Galaxy (game-play and simulation server)
* [starpeace-server-galaxy-api](https://github.com/starpeace-project/starpeace-server-galaxy-api) - STARPEACE Galaxy API interface
* [starpeace-server-galaxy-nodejs](https://github.com/starpeace-project/starpeace-server-galaxy-nodejs) - STARPEACE Galaxy implementation in NodeJS using express

### Misc
* [starpeace-assets](https://github.com/starpeace-project/starpeace-assets) - raw media assets, gameplay resources, and simulation configurations
* [starpeace-documents-public](https://github.com/starpeace-project/starpeace-documents-public) - public design, planning, and gameplay documents
* [starpeace-project-website](https://github.com/starpeace-project/starpeace-project-website) - project static content, auto-generated API documentation, and community information

### Design Decisions

When we make a significant decision in how we maintain the project and what we can or cannot support, we will document it in the [starpeace-documents-public](https://github.com/starpeace-project/starpeace-documents-public) or [starpeace-documents-private](https://github.com/starpeace-project/starpeace-documents-private) repositories. If you have a question around how we do things, check to see if it is documented there. If it is *not* documented there, please join [Discord chatroom](https://discord.gg/TF9Bmsj) and ask your question.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report for STARPEACE. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

When you are creating a bug report, please [include as many details as possible](#how-do-i-submit-a-good-bug-report). Fill out [the required template](ISSUE_TEMPLATE.md), the information it asks for helps us resolve issues faster.

> **Note:** If you find a **Closed** issue that seems like it is the same thing that you're experiencing, open a new issue and include a link to the original issue in the body of your new one.

#### How Do I Submit A (Good) Bug Report?

Bugs are tracked as [GitHub issues](https://guides.github.com/features/issues/); create an issue and provide the following information by filling in [the template](ISSUE_TEMPLATE.md).

Explain the problem and include additional details to help maintainers reproduce the problem:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as many details as possible.
* **Explain which behavior you expected to see instead and why.**
* **Include screenshots and animated GIFs** which show you following the described steps and clearly demonstrate the problem. You can use [this tool](https://www.cockos.com/licecap/) to record GIFs on macOS and Windows, and [this tool](https://github.com/colinkeenan/silentcast) or [this tool](https://github.com/GNOME/byzanz) on Linux.
* **Include console output from developer tools pane where possible**, including any details and stacktraces of ERROR log messages displayed.
* **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened and share more information using the guidelines below.

Provide more context by answering these questions:

* **Did the problem start happening recently** (e.g. recent version of STARPEACE) or was this always a problem?
* **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.

Include details about your configuration and environment:

* **Which version of STARPEACE did you see the problem?** Version and client build information is located on screen, near the lower-right corner.
* **What's the name and version of the OS you're using**?
* **What's the name and version of the web browser you're using**?
* **What screen resolution and window size do you have**?

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for STARPEACE, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion and find related suggestions.

Before creating enhancement suggestions, please check [this list](#before-submitting-an-enhancement-suggestion) as you might find out that you don't need to create one. When you are creating an enhancement suggestion, please [include as many details as possible](#how-do-i-submit-a-good-enhancement-suggestion). Fill in [the template](ISSUE_TEMPLATE.md), including the steps that you imagine you would take if the feature you're requesting existed.

#### Before Submitting An Enhancement Suggestion

* **Perform a [cursory search](https://github.com/starpeace-project/starpeace-website-client/issues?utf8=%E2%9C%93&q=is%3Aissue)** to see if the enhancement has already been suggested. If it has, add a comment to the existing issue instead of opening a new one.

#### How Do I Submit A (Good) Enhancement Suggestion?

Enhancement suggestions are tracked as [GitHub issues](https://guides.github.com/features/issues/); provide the following information when creating an issue:

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
* **Provide specific examples to demonstrate the steps**. Include copy/pasteable snippets which you use in those examples, as [Markdown code blocks](https://help.github.com/articles/markdown-basics/#multiple-lines).
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Include screenshots and animated GIFs** which help you demonstrate the steps or point out the part of STARPEACE which the suggestion is related to. You can use [this tool](https://www.cockos.com/licecap/) to record GIFs on macOS and Windows, and [this tool](https://github.com/colinkeenan/silentcast) or [this tool](https://github.com/GNOME/byzanz) on Linux.
* **Explain why this enhancement would be useful** to most players
* **Specify the name and version of the OS you're using.**

### Your First Code Contribution

Unsure where to begin contributing to STARPEACE? Join [Discord chatroom](https://discord.gg/TF9Bmsj) to discuss possible work or [look through any existing issues](https://github.com/starpeace-project/starpeace-website-client/issues) or [project tasks for ideas](https://github.com/starpeace-project/starpeace-website-client/projects).

#### Local development

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

### Pull Requests

The process described here has several goals:

- Maintain STARPEACE's quality and performance
- Fix problems and add features that are important to users
- Enable a sustainable system for STARPEACE's maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. Follow all instructions in [the template](PULL_REQUEST_TEMPLATE.md)
2. Follow the [styleguides](#styleguides)
3. After you submit your pull request, please engage project team for feedback and testing verification

While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.

### Translations

STARPEACE is a global game with an international player-base, making language translations an important aspect of project. starpeace-website-client aims to support the following languages:

* English, French, Portuguese, German, Italian, and Spanish

If you'd like to see STARPEACE translated to your native language and can provide translations, or can help improve any existing translations, please [create an issue](https://github.com/starpeace-project/starpeace-website-client/issues) or [chat with project team](https://discord.gg/TF9Bmsj).


## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

### JavaScript Styleguide

Coffeescript is preferred, though if used, all JavaScript must adhere to [JavaScript Standard Style](https://standardjs.com/).

* Prefer the object spread operator (`{...anotherObj}`) to `Object.assign()`
* Inline `export`s with expressions whenever possible
  ```js
  // Use this:
  export default class ClassName {

  }

  // Instead of:
  class ClassName {

  }
  export default ClassName
  ```
* Place requires in the following order, then alphabetically:
    * Built in Node Modules (such as `path`)
    * Third-party Modules (such as `PIXI`)
    * Local Modules (using relative paths)
* Place class properties in the following order:
    * Class methods and properties (methods starting with `static`)
    * Instance methods and properties

### CoffeeScript Styleguide

* Set parameter defaults without spaces around the equal sign
    * `clear = (count=1) ->` instead of `clear = (count = 1) ->`
* Use spaces around operators
    * `count + 1` instead of `count+1`
* Use spaces after commas (unless separated by newlines)
* Use parentheses if it improves code clarity.
* Avoid spaces inside the curly-braces of hash literals:
    * `{a: 1, b: 2}` instead of `{ a: 1, b: 2 }`
* Include a single line of whitespace between methods.
* Capitalize initialisms and acronyms in names, except for the first word, which
  should be lower-case:
  * `getURI` instead of `getUri`
  * `uriToOpen` instead of `URIToOpen`
* Use `slice()` to copy an array
* Add an explicit `return` when your function ends with a `for`/`while` loop and
  you don't want it to return a collected array.
* Use `@` instead of a standalone `this`
  * `@method_call()` instead of `this.method_call()`
  * `return @` instead of `return this`
* Place requires in the following order, then alphabetically:
    * Built in Node Modules (such as `path`)
    * Third-party Modules (such as `PIXI`)
    * Local Modules (using relative paths)
* Place class properties in the following order:
    * Class methods and properties (methods starting with a `@`)
    * Instance methods and properties

### SASS Styleguide


### Pug Styleguide


### Vue and Nuxtjs Styleguide
