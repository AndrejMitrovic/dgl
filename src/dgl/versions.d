/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.versions;

struct DGL_Versions
{
    version(dgl_use_derelict)
        enum bool use_derelict = true;
    else
        enum bool use_derelict = false;

    version(dgl_use_glad)
        enum bool use_glad = true;
    else
        enum bool use_glad = false;
}
