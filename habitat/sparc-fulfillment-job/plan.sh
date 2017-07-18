pkg_name=sparc-fulfillment-job
pkg_origin=chrisortman
pkg_version="2.4.0"
pkg_source="http://some_source_url/releases/${pkg_name}-${pkg_version}.tar.gz"
pkg_shasum="TODO"
pkg_deps=(chrisortman/sparc-fulfillment/$pkg_version)

pkg_binds=(
  [base]="rails-port"
)

do_begin() {
  return 0
}
do_download() {
  return 0
}
do_verify() {
  return 0
}
do_clean() {
  do_default_clean
}
do_unpack() {
  return 0
}
do_prepare() {
  return 0
}
do_build() {
  return 0
}
do_check() {
  return 0
}
do_install() {
  return 0
}
do_strip() {
  return 0
}
do_end() {
  return 0
}

