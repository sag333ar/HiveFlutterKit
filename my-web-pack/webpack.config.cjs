const { DefinePlugin, ProvidePlugin } = require('webpack')
const path = require('path');
const webpack = require('webpack');

module.exports = {
  entry: './src/index.js', 
  output: {
    filename: 'bundle.js',
    path: path.resolve('../web', ''),
  },
  optimization: {
    splitChunks: {
      cacheGroups: {
        default: false,
      },
    },
    runtimeChunk: false,
    mergeDuplicateChunks: true,
    concatenateModules: true
  },
  resolve: {
    fallback: {
      url: false,
      buffer: require.resolve('buffer/')
    }
  },
  plugins: [
    new DefinePlugin({
      'process.env.NODE_DEBUG': false
    }),
    new DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production'),
    }),
    new webpack.optimize.LimitChunkCountPlugin({
         maxChunks: 1
     }),
    new ProvidePlugin({
      Buffer: ['buffer', 'Buffer']
    })
  ]
}