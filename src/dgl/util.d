/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dgl.util;

/** Return the memory size needed to store the elements of the array. */
package size_t memSizeOf(E)(E[] arr)
{
    return E.sizeof * arr.length;
}

///
unittest
{
    int[] arrInt = [1, 2, 3, 4];
    assert(arrInt.memSizeOf == 4 * int.sizeof);

    long[] arrLong = [1, 2, 3, 4];
    assert(arrLong.memSizeOf == 4 * long.sizeof);
}
