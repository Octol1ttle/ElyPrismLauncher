# SPDX-FileCopyrightText: 2023 David Faure <faure@kde.org>
#
# SPDX-License-Identifier: BSD-3-Clause

#[=======================================================================[.rst:
ECMFeatureSummary
-----------------

Call feature_summary(), except when being called from a subdirectory.
This ensures that frameworks being used as submodules by third-party applications
do not call feature_summary(), so that it doesn't end up being called multiple
times in the same cmake run.


::

  include(ECMFeatureSummary)
  ecm_feature_summary([... see feature_summary documentation ...])

Example:

.. code-block:: cmake

  find_package(ECM REQUIRED)
  include(ECMFeatureSummary)
  ecm_feature_summary(WHAT ALL   FATAL_ON_MISSING_REQUIRED_PACKAGES)

Since 5.247
#]=======================================================================]

include(FeatureSummary)
function(ecm_feature_summary)

    if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
       feature_summary(${ARGV})
    endif()

endfunction()
