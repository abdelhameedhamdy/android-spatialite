/**********************************************************************
 * $Id$
 *
 * GEOS - Geometry Engine Open Source
 * http://geos.refractions.net
 *
 * Copyright (C) 2008 Sean Gillies
 *
 * This is free software; you can redistribute and/or modify it under
 * the terms of the GNU Lesser General Public Licence as published
 * by the Free Software Foundation. 
 * See the COPYING file for more information.
 *
 **********************************************************************
 *
 * Last port: ORIGINAL WORK
 *
 **********************************************************************/

#include <geos/io/CLocalizer.h>

#include <string>
#include <clocale>

using namespace std;

namespace geos {
namespace io {

CLocalizer::CLocalizer()
{
#ifndef __ANDROID__
    char* p = std::setlocale(LC_NUMERIC, NULL);
    if (0 != p)
    {
        saved_locale = p;
    }
    std::setlocale(LC_NUMERIC, "C");
#endif
}

CLocalizer::~CLocalizer()
{
#ifndef __ANDROID__
    std::setlocale(LC_NUMERIC, saved_locale.c_str());
#endif
}

} // namespace geos.io
} // namespace geos

