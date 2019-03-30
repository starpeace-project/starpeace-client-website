module.exports = {
  plugins: [
    require('postcss-preset-env')({
      browserslist: ["> 1%", "last 2 versions"],
      features: {
        customProperties: false
      }
    }),
    require('postcss-import')()
  ]
}
