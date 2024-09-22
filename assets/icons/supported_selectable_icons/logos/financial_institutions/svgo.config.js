module.exports = {
  multipass: true,
  plugins: [
    {
      name: 'preset-default',
      params: {
        overrides: {
          // Disable the cleanupIDs plugin as it's not supported in the default preset anymore
          // Enable this to inline styles and remove CSS classes
          inlineStyles: true,
          removeStyleElement: true,  // Removes <style> blocks
        },
      },
    },
    {
      name: 'convertStyleToAttrs',  // Converts styles to attributes
      active: true,
    },
  ],
};
