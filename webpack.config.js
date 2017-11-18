const path = require('path');

module.exports = {
  entry: {
    browser: './src/Browser.jsx',
  },
  output: {
    path: path.resolve('dist'),
    filename: '[name].js',
  },
  target: 'electron-renderer',
  module: {
    loaders: [
      {
        test: /\.jsx?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
      },
      {
        test: /\.css/,
        use: 'raw-loader',
        exclude: /node_modules/,
      },
    ],
  },
};
