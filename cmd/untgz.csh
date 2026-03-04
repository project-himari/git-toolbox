#!/bin/csh

foreach file (*.tgz)
    tar -zxvf $file
end
