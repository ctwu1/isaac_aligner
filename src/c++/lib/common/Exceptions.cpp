/**
 ** Isaac Genome Alignment Software
 ** Copyright (c) 2010-2014 Illumina, Inc.
 ** All rights reserved.
 **
 ** This software is provided under the terms and conditions of the
 ** BSD 2-Clause License
 **
 ** You should have received a copy of the BSD 2-Clause License
 ** along with this program. If not, see
 ** <https://github.com/sequencing/licenses/>.
 **
 ** \file Exceptions.cpp
 **
 ** \brief Implementation of the common exception mechanism.
 **
 ** \author Come Raczy
 **/

#include <cstring>
#include <cerrno>
#include <boost/date_time.hpp>

#include "common/Exceptions.hh"

namespace isaac
{
namespace common
{

ExceptionData::ExceptionData(int errorNumber, const std::string &message) : boost::exception(),
            errorNumber_(errorNumber), message_(message)
{
}

std::string ExceptionData::getContext() const
{
    const std::string now = boost::posix_time::to_simple_string(boost::posix_time::second_clock::local_time());
    return now + ": " + std::string(strerror(errorNumber_)) + ": " + boost::diagnostic_information(*this);
}

IoException::IoException(int errorNumber, const std::string &message)
    : std::ios_base::failure(message)
    , ExceptionData(errorNumber, message)
{
}

ResourceException::ResourceException(int errorNumber, const std::string &message)
    : ExceptionData(errorNumber, message)
{
}


MemoryException::MemoryException(const std::string &message)
    : std::bad_alloc(),
      ExceptionData(ENOMEM, message)
{
}

UnsupportedVersionException::UnsupportedVersionException(const std::string &message)
    : std::logic_error(message)
    , ExceptionData(EINVAL, message)
{
}

FeatureNotAvailable::FeatureNotAvailable(const std::string &message)
    : std::logic_error(message)
    , ExceptionData(EINVAL, message)
{
}

InvalidParameterException::InvalidParameterException(const std::string &message)
    : std::logic_error(message)
    , ExceptionData(EINVAL, message)
{
}

InvalidOptionException::InvalidOptionException(const std::string &message)
    : std::logic_error(message)
    , ExceptionData(EINVAL, message)
{
}

PreConditionException::PreConditionException(const std::string &message)
    : std::logic_error(message)
    , ExceptionData(EINVAL, message)
{
}

PostConditionException::PostConditionException(const std::string &message)
    : std::logic_error(message)
    , ExceptionData(EINVAL, message)
{
}

LibXsltException::LibXsltException()
    : IsaacException(EINVAL, "libxslt failure")
{
}

} // namespace common
} // namespace isaac
