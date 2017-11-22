const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require('path');

module.exports = {
  entry: {
    browser: './src/components/Browser.jsx',
    settings: './src/components/Settings.jsx',
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
        use: 'babel-loader',
        exclude: /node_modules/,
      },
      {
        test: /\.css$/,
        use: 'raw-loader',
        include: path.resolve(__dirname, 'src/components/css/webview/'),
        exclude: /node_modules/,
      },
      {
        test: /\.css$/,
        exclude: /(node_modules|webview)/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: 'Settings',
      filename: 'settings.html',
      chunks: ['settings'],
    }),
  ],
};
