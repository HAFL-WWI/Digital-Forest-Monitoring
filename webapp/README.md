# Digital-Forest-Monitoring

### Forest monitoring apps and services based on remote sensing data.

#### An online version of the app can be found here: [https://forestmonitoring.lab.karten-werk.ch](https://forestmonitoring.lab.karten-werk.ch)

## Getting Started

You can get a local copy of the project by running this command on your console:

```
git clone git@github.com:HAFL-FWI/Digital-Forest-Monitoring.git
```

After that, you should have a new directory named "Digital-Forest-Monitoring". Enter it by typing...
`cd Digital-Forest-Monitoring/webapp`.

### Prerequisites

The project needs the package manager [Yarn](https://yarnpkg.com/). You can install it from [here](https://yarnpkg.com/en/docs/install).
Also it is very recommended to install the version control system [Git](https://git-scm.com/) on your machine.

### Installing

While in the newly created folder, install all the dependencies.

```zsh
yarn install
```

After that, you can start a development server by enter the following command...

```zsh
yarn run start
```

This command starts the bundling process and opens the development server on port 1234 => [http://localhost:1234](http://localhost:1234).

## Deployment

```zsh
yarn run build
```

This disables watch mode and hot module replacement so it will only build once. It also enables the minifier for all output bundles to reduce file size. The minifiers used by Parcel are [terser](https://github.com/terser/terser) for JavaScript, [cssnano](https://cssnano.co/) for CSS, and [htmlnano](https://github.com/posthtml/htmlnano) for HTML.
After that, you can copy the contents of the `dist` folder to your webservers root directory.

## Linting

This project uses [eslint](https://eslint.org/). You can start the linter by typing `yarn run lint`. It it recommended to integrate the linter in the IDE of your choice. See [https://eslint.org/docs/user-guide/integrations](https://eslint.org/docs/user-guide/integrations) for more info.
Altough it's not integrated in this project, we use [Prettier](https://prettier.io/) in order to format the code. Prettier can be integrated in [various IDE's](https://prettier.io/docs/en/editors.html) and we recommend it very much.

## Built with

- [YARN](https://yarnpkg.com/) - Package Management
- [parcel](https://parceljs.org/) - Blazing fast, zero configuration web application bundler
- [Navigo](https://github.com/krasimir/navigo) A simple vanilla JavaScript router with a fallback for older browsers.
- [OpenLayers](https://openlayers.org/) A high-performance, feature-packed library for all your mapping needs.

## Contributing

Of course, this project can be extended.
Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning.

## Authors (in alphabetical order)

- Alexandra Erbach (HAFL)
- Christian Rosset (HAFL)
- Dominique Weber (HAFL)
- Hanskaspar Frei (karten-werk GmbH)
- Thomas Bettler (BAFU)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Bundesamt für Umwelt (BAFU)](https://www.bafu.admin.ch/bafu/de/home/themen/wald.html)
- [Hochschule für Agrar-, Forst- und Lebensmittelwissenschaften HAFL](https://www.bfh.ch/hafl/de/)
