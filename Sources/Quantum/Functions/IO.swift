/*
 Saving effort used for old-school debugging and terminal messages.
 */

import Foundation

public struct StandardErrorOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errorStream = StandardErrorOutputStream()


// Created by M J Everitt on 21/01/2022.

