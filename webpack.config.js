const webpack = require('webpack');
const path = require('path');
const nodeEnv = process.env.NODE_ENV;
const isProduction = true;
let serverScriptPath = path.join( __dirname, 'proto/wtools/atop/docgen/l4/server/server.ss' )
let docsifyAppDirPath = path.join( __dirname, 'proto/wtools/atop/docgen/l4/docsify-app' )

// Common plugins
let plugins = [
    new webpack.DefinePlugin({
        'process.env': {
            NODE_ENV: JSON.stringify(nodeEnv),
        },
    }),
    new webpack.NamedModulesPlugin()
];
if (!isProduction) {
    plugins.push(new webpack.HotModuleReplacementPlugin())
}
const entry = isProduction ? [
  'babel-polyfill',
  path.resolve( serverScriptPath )
] : [
  'webpack/hot/poll?1000',
  'babel-polyfill',
  path.resolve( serverScriptPath )
];
module.exports = {
    mode: 'production',
    devtool: false,
    externals: [],
    name : 'server',
    plugins: plugins,
    target: 'node',
    entry: entry,
    output: {
        publicPath: './',
        path: path.resolve( docsifyAppDirPath ),
        filename: 'server.ss',
        libraryTarget: "commonjs2"
    },
    resolve: {
        extensions: ['.webpack-loader.js', '.web-loader.js', '.loader.js', '.js', '.jsx'],
        modules: [
            path.resolve(__dirname, 'node_modules')
        ]
    },
    module : {
        rules: [
            {
                test: /\.(js|jsx)$/,
                loader: "babel-loader",
                options : {
                    babelrc : true
                }
            }
        ],
    },
    node: {
        console: false,
        global: false,
        process: false,
        Buffer: false,
        __filename: false,
        __dirname: false,
    }
};