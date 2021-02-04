#!/usr/bin/env coffee
import ROOT from "./dir/root"
import {join} from 'path'
import fs from 'fs'

export default (fp)=>
  r = []
  for i in fs.readFileSync(join(ROOT, fp),"utf8").split("\n")
    i = i.trim()
    if i
      r.push i
  return r
