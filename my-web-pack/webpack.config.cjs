const { DefinePlugin, ProvidePlugin } = require('webpack')

module.exports = {
  // ...
  resolve: {
    // ...
    fallback: {
      url: false,
      buffer: require.resolve('buffer/')
    }
  },
  plugins: [
    // ...
    new DefinePlugin({
      'process.env.NODE_DEBUG': false
    }),
    new ProvidePlugin({
      Buffer: ['buffer', 'Buffer']
    })
  ]
}