# Troubleshooting

If there are failures with SSL certificate errors, you may need to tell Git the location of your system SSL certificates.
This can be an issue particularly on HPC with ancient certificates.
Assuming SSL certificates are at "/etc/ssl/certs/ca-bundle.crt", do these two steps from Terminal (not Matlab), one time.

Edit ~/.bashrc or ~/.zshrc to have

```sh
export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
```

Then run:

```sh
git config --global http.sslCAInfo /etc/ssl/certs/ca-bundle.crt
```
