# SPDX-FileCopyrightText: 2016 Pino Toscano <pino@kde.org>
# SPDX-FileCopyrightText: 2021 Volker Krause <vkrause@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
FindIsoCodes
------------

Try to find iso-codes data files.
Once done this will define:

``IsoCodes_FOUND``
      Whether the system has iso-codes
``IsoCodes_PREFIX``
      The location in which the iso-codes data files are found
``IsoCodes_DOMAINS``
      The available domains provided by iso-codes

Since 5.80.0.
#]=======================================================================]

find_package(PkgConfig QUIET)
pkg_check_modules(PKG_iso_codes QUIET iso-codes)

set(IsoCodes_VERSION ${PKG_iso_codes_VERSION})
set(IsoCodes_PREFIX ${PKG_iso_codes_PREFIX})
pkg_get_variable(IsoCodes_DOMAINS iso-codes domains)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(IsoCodes
    FOUND_VAR IsoCodes_FOUND
    REQUIRED_VARS IsoCodes_DOMAINS IsoCodes_PREFIX
    VERSION_VAR IsoCodes_VERSION
)

include(FeatureSummary)
set_package_properties(IsoCodes PROPERTIES
  URL "https://salsa.debian.org/iso-codes-team/iso-codes"
  DESCRIPTION "Data about various ISO standards (e.g. country, language, language scripts, and currency names)"
)
