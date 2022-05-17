const refreshTodosButton = document.querySelector("#refresh-todos");
const signOutButton = document.querySelector("#sign-out");
const dateElement = document.querySelector("#date");
const list = document.querySelector("#list");
const input = document.querySelector("#input");

const CHECK = "fa-check-circle";
const UNCHECK = "fa-circle-thin";
const LINE_THROUGH = "lineThrough";

let LIST, id;

// get item from localstorage
let data = localStorage.getItem("TONOTDO");

// check if data is not empty
if(data) {
    LIST = JSON.parse(data);
    // set the id to the last one in the list
    id = LIST.length;
    // load the list to the user interface
    loadList(LIST);
}else{
    // if data isn't empty
    LIST = [];
    id = 0;
}

// load items to the user's interface
function loadList(array){
    array.forEach(function(item){
        addToNotDo(item.name, item.id, item.done, item.trash);
    });
}

function getUserId() {
  const sessionCookie = document.cookie.split('&').find((val) => val.split('=')[0] == '_session_id')
  if (sessionCookie) {
    const userId = JSON.parse(window.unescape(sessionCookie.split('=')[1]))
    return userId['id']
  }
}

function getUserName() {
  const sessionCookie = document.cookie.split('&').find((val) => val.split('=')[0] == '_session_id')
  if (sessionCookie) {
    const userId = JSON.parse(window.unescape(sessionCookie.split('=')[1]))
    return userId['name']
  }
}

// clear the local storage
refreshTodosButton.addEventListener("click", () => {

    window.location.reload()
});

signOutButton.addEventListener('click', () => {
  fetch('/sign_out', { method: 'DELETE' }).then((response) => {
    if (response.ok) { window.location.reload() }
  })
})

// display today's date
const options = {weekday : "long", month:"short", day:"numeric"};
const today = new Date();

let time = new Date();
let n = time.getHours();
if (n > 21 || n < 4)
    document.getElementById('background').style.backgroundImage="url(../img/night.png)";
else if (n >= 4 && n < 8)
    document.getElementById('background').style.backgroundImage="url(../img/dawn.png)";
else if (n > 8 && n < 17)
    document.getElementById('background').style.backgroundImage="url(../img/day.png)";
else if (n >= 17 && n < 21)
    document.getElementById('background').style.backgroundImage="url(../img/dusk.png)";

dateElement.innerHTML = today.toLocaleDateString("en-US", options);

function addToNotDo(toNotDo, id, done, trash){

    if(trash){ return; }

    const DONE = done ? CHECK : UNCHECK;
    const LINE = done ? LINE_THROUGH : "";

    const item = `<li class="item">
                    <i class="fa ${DONE} complete" data-job="complete" id="${id}"></i>
                    <p class="text ${LINE}">${toNotDo}</p>
                    <i class="fa fa-trash-o del" data-job="delete" id="${id}"></i>
                  </li>
                `;

    const position = "beforeend";

    list.insertAdjacentHTML(position, item);
}

// add an item to the list user the enter key
document.addEventListener("keyup",function(even){
    if(event.keyCode === 13){
        const toNotDo = input.value;
        // if the input isn't empty
        if(toNotDo){
            addToNotDo(toNotDo, id, false, false);

            LIST.push({
                name : toNotDo,
                id : ((new Date()).getTime() + "").slice(8) + id,
                done : false,
                trash : false
            });
            localStorage.setItem("TONOTDO", JSON.stringify(LIST));
            id++;
        }
        input.value = "";
    }
});

// complete to do
function completeToNotDo(element){
    element.classList.toggle(CHECK);
    element.classList.toggle(UNCHECK);
    element.parentNode.querySelector(".text").classList.toggle(LINE_THROUGH);

    const todo = LIST.find(el => el.id.toString() === element.id.toString())
    const todoIndex = LIST.findIndex(el => el.id.toString() === element.id.toString())
    todo.done = !todo.done

    LIST[todoIndex] = todo
}

// remove to do
function removeToNotDo(element){
    element.parentNode.parentNode.removeChild(element.parentNode);

    const todo = LIST.find(el => el.id.toString() === element.id.toString())
    const todoIndex = LIST.findIndex(el => el.id.toString() === element.id.toString())
    todo.trash = true

    LIST[todoIndex] = todo
}

// target the items created dynamically

list.addEventListener("click", function(event){
    // event.preventDefault()
    const element = event.target; // return the clicked element inside list
    const elementJob = element.dataset.job; // complete or delete

    if(elementJob == "complete"){
        completeToNotDo(element);
    }else if(elementJob == "delete"){
        removeToNotDo(element);
    }
    localStorage.setItem("TONOTDO", JSON.stringify(LIST));
});

function syncTodos() {
  const userId = getUserId()
  const todos = LIST.map(todo => { return {
    user_id: userId,
    ...todo
  }})
  fetch(`/sync?user_id=${userId}`, { method: "POST", body: JSON.stringify({ data: todos}), headers: { 'Content-Type': 'application/json' }  }).then((response) => {
    if (response.ok) {
      response.json().then(data => {
        localStorage.clear();
        list.innerHTML = ""
        loadList(data)

        LIST = data
      })
    }
  })
}

setTimeout(() => syncTodos(), 500)
setInterval(() => syncTodos(), 10000)

setTimeout(() => {
  const greeting = document.querySelector('#name')
  greeting.innerHTML = 'Hi, ' + getUserName()
})
