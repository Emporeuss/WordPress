<?php
define( 'WP_CACHE', true );
/** Enable W3 Total Cache */
 // Added by W3 Total Cache

/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'emporeuss_wp725' );

/** Database username */
define( 'DB_USER', 'emporeuss_wp725' );

/** Database password */
define( 'DB_PASSWORD', '.SY7.v3(72pUP[' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'y3rk9lhitmsoqrgmjj7hz6ydwyp0vgcauqkq2rnbyowchdrrhjqyirlg7xpm2njz' );
define( 'SECURE_AUTH_KEY',  '0nzlp9edoylstwarcqd8zd2lvo29lfdg5heksnzemidn3ibejjd3uvpho7bvul00' );
define( 'LOGGED_IN_KEY',    'q7ix9c9p9ukt5clhettz7l5qzsx2dmfkzssmewshkocdmfakjmo7zss9bqeegofp' );
define( 'NONCE_KEY',        'wiu08u1rwq1jtxgwwvl05ksl5awot0c545xxfxpfxr1lopk9yf7aga7ite0ssaoh' );
define( 'AUTH_SALT',        '8zbuemq7loquatsbg47rf4fo5sxkmqnuuqbmolumxvzpr6kidun7zygfva9y040u' );
define( 'SECURE_AUTH_SALT', '9zpjpqtfhmmflqjbqbcivqhlg1h0irr9ljfcegkvsyhd29xhxpslgnkzi0enfosr' );
define( 'LOGGED_IN_SALT',   'yjdf5khg5dhskhfbu1cydizuuvid0gfu8vh2wfvbjqy7pdiguqalil57zfvyuqbl' );
define( 'NONCE_SALT',       'ufmr6kyvxcl25b0diixalfx5giqyriwnrqzhw7wzaj86waftnyselu057rrqygxd' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp7t_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
