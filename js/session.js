function getError() {
  const errorsCookie = document.cookie.split('; ').find((val) => val.split('=')[0] == 'errors')
  if (errorsCookie) {
    const cookieData = JSON.parse(window.unescape(errorsCookie.split('=')[1]))
    return cookieData.message.replaceAll('+', ' ')
  }
}

function removeErrorCookie() {
  let cookies = document.cookie.split('; ')
  const errorsCookieIndex = cookies.findIndex((val) => val.split('=')[0] == 'errors')
  cookies.pop(errorsCookieIndex)
  cookies.push("errors=; expires=Fri, 31 Dec 2000 23:59:59 GMT")
  document.cookie = cookies.join('; ')
}

function setError() {
  const errors = getError()
  if (!errors) return
  removeErrorCookie()
  const errorsContainer = document.querySelector('#errors')

  errorMessage = document.createElement('p')
  errorMessage.innerHTML = errors
  errorsContainer.appendChild(errorMessage)
}

setError()

