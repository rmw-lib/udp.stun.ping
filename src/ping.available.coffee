#!/usr/bin/env coffee
import txtli from './txtli'
import fs from 'fs'
import {join} from 'path'
import {thisdir} from "@rmw/thisfile"
import shuffle from 'lodash/shuffle'
import stun from 'stun'
import {promisify} from 'util'
import dgram from 'dgram'
import sleep from 'await-sleep'

request = promisify(stun.request)

stunPing = (hostIp)=>
  new Promise (resolve)=>
    # https://github.com/nodertc/stun/pull/15/files
    # Pass network errors to server instead of crashing
    socket = dgram.createSocket('udp4')
    socket.bind()
    address = await new Promise (res)=>
      socket.on('listening', =>
        res socket.address()
      )
    socket.on('error',(err)=>
      resolve()
      return
    )
    socket.on('close',=>
      # console.log "end", address
      return
    )
    result = await do =>
      n = 0
      while ++n<9
        try
          r = await request(
            hostIp
            {
              socket
              maxTimeout:3000
            }
          )
        catch err
          if err.message !="timeout" and err.code != "ENOTFOUND"
            console.error "❌",hostIp,err
            console.log err.code, err.message
            console.trace()
          continue
        addr = r.getAddress()
        if addr and addr.address
          console.log hostIp, addr.address
          resolve hostIp
          return
      resolve()
      return
    socket.close()
    return

main = =>
  todo = []
  exist = new Set()
  for hostIp from shuffle(txtli('stun.all.txt'))
    if not exist.has hostIp
      exist.add hostIp
      todo.push stunPing(hostIp)

  r = await Promise.all todo
  console.log r
  r = (i for i in r when i)
  r.sort()

  fs.writeFileSync(
    join(thisdir(`import.meta`), "stun.txt"),
    r.join("\n")
  )
  process.exit()

main()
