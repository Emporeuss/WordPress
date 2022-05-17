<?php
define( 'WP_CACHE', true );












/** Enable W3 Total Cache */
 // Added by W3 Total Cache

/** Enable W3 Total Cache */

/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'emporeuss_wp298' );

/** MySQL database username */
define( 'DB_USER', 'emporeuss_wp298' );

/** MySQL database password */
define( 'DB_PASSWORD', 'd855SLGT)p[)0@' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '9rfacudld0mq6q2bxyxhhdjmaribqomevqfonzw8u7sxkwatq36yohklwtrp2mfg' );
define( 'SECURE_AUTH_KEY',  'xxrseb29gzxgoqoqunfwg58h0vupky23zpctqr0yqhhpyhq7ye5b9of65v4zpvma' );
define( 'LOGGED_IN_KEY',    'tmpbe7d7lkkawiqyvhvibagrnlm7vtwc9y3oew4tzhiirwmmh6dj0vvebr3g17ot' );
define( 'NONCE_KEY',        'mqowckpadk1pxffxqiwoe24ck9xfw7lzqqbxz8lt8wszlqg4qchewcppvazelwrg' );
define( 'AUTH_SALT',        '5pvhqb3zw5idzs0hjknqn5yd6j5skzduojhdtob6a5gsvh7sk5lclnuinrmm8k3q' );
define( 'SECURE_AUTH_SALT', 'c7ms9ibcnkox4hnlaqcl8vmmh1wivpbfqihegwmyh0fyyaherjwgghkibssn2y1p' );
define( 'LOGGED_IN_SALT',   'pnxxlwqji2b53rkbfcvzfdtw28kvbzrzkv3nabcrcltf2pzcdcbcplhssfiufbvu' );
define( 'NONCE_SALT',       'dp6yj8a59ojgjed2gvpbl6fwjeqxgkgbunbb3n52aezlyvxtyostqoehrtm3cvv7' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wptc_';

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

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
