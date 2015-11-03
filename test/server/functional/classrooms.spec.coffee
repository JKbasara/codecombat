config = require '../../../server_config'
require '../common'
utils = require '../../../app/core/utils' # Must come after require /common
mongoose = require 'mongoose'

classroomsURL = getURL('/db/classroom')

describe 'GET /db/classrooms/:id', ->
  it 'Clear database users and clans', (done) ->
    clearModels [User, Classroom], (err) ->
      throw err if err
      done()

  it 'creates a new classroom for the given user', (done) ->
    loginNewUser (user1) ->
      data = { name: 'Classroom 1' }
      request.post {uri: classroomsURL, json: data }, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        classroomID = body._id
        request.get {uri: classroomsURL + '/'  + body._id }, (err, res, body) ->
          expect(res.statusCode).toBe(200)
          expect(body._id).toBe(classroomID = body._id)
          done()

describe 'POST /db/classrooms', ->
  
  it 'Clear database users and clans', (done) ->
    clearModels [User, Classroom], (err) ->
      throw err if err
      done()

  it 'creates a new classroom for the given user', (done) ->
    loginNewUser (user1) ->
      data = { name: 'Classroom 1' }
      request.post {uri: classroomsURL, json: data }, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        expect(body.name).toBe('Classroom 1')
        expect(body.members.length).toBe(0)
        expect(body.ownerID).toBe(user1.id)
        done()
        
  it 'does not work for anonymous users', (done) ->
    logoutUser ->
      data = { name: 'Classroom 2' }
      request.post {uri: classroomsURL, json: data }, (err, res, body) ->
        expect(res.statusCode).toBe(401)
        done()
        
        
describe 'PUT /db/classrooms', ->

  it 'Clear database users and clans', (done) ->
    clearModels [User, Classroom], (err) ->
      throw err if err
      done()

  it 'edits name and description', (done) ->
    loginNewUser (user1) ->
      data = { name: 'Classroom 2' }
      request.post {uri: classroomsURL, json: data }, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        data = { name: 'Classroom 3', description: 'New Description' }
        url = classroomsURL + '/' + body._id
        request.put { uri: url, json: data }, (err, res, body) ->
          expect(body.name).toBe('Classroom 3')
          expect(body.description).toBe('New Description')
          done()
          
  it 'is not allowed if you are just a member', (done) ->
    loginNewUser (user1) ->
      data = { name: 'Classroom 4' }
      request.post {uri: classroomsURL, json: data }, (err, res, body) ->
        expect(res.statusCode).toBe(200)
        classroomCode = body.code
        loginNewUser (user2) ->
          url = classroomsURL + '/' + body._id + '/members'
          data = { code: classroomCode }
          request.post { uri: url, json: data }, (err, res, body) ->
            expect(res.statusCode).toBe(200)
            url = classroomsURL + '/' + body._id
            request.put { uri: url, json: data }, (err, res, body) ->
              expect(res.statusCode).toBe(403)
              done()
            
describe 'POST /db/classrooms/:id/members', ->
  
  it 'adds the signed in user to the list of members in the classroom', (done) ->
    loginNewUser (user1) ->
      data = { name: 'Classroom 5' }
      request.post {uri: classroomsURL, json: data }, (err, res, body) ->
        classroomCode = body.code
        expect(res.statusCode).toBe(200)
        loginNewUser (user2) ->
          url = classroomsURL + '/' + body._id + '/members'
          data = { code: classroomCode }
          request.post { uri: url, json: data }, (err, res, body) ->
            expect(res.statusCode).toBe(200)
            done()
