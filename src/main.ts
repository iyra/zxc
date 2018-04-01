import * as m from 'mithril';

class Player {
    private _name: string;
    constructor(name: string) {
	this._name = name;
    }

    set name(newName: string) {
	this._name = newName;
    }

    get name(): string {
	return this._name;
    }
    
    greet() {
	return "Hi, " + this._name;
    }
}

class Choice {
    description: string;
    destination: string;

    constructor(desc: string, dest: string) {
	this.description = desc;
	this.destination = dest;
    }
}

class Scene {
    name: string;
    description: string;
    choices: Choice[];
    checker: (p: Player) => boolean;
    loadAction: (p: Player) => Player;
    endAction: (p: Player) => Player;
    endOfGame: boolean;

    constructor(name: string,
		desc: string,
		cs: Choice[],
		chk: (p: Player) => boolean,
		la: (p: Player) => Player,
		ea: (p: Player) => Player,
		eog: boolean) {
	this.name = name;
	this.description = desc;
	this.choices = cs;
	this.checker = chk;
	this.loadAction = la;
	this.endAction = ea;
	this.endOfGame = eog;
    }

    getChoice() {
	let i: number = 1;
	for(var c of this.choices) {
	    console.log(i+". "+c.description);
	    i++;
	}
    }
}

class Game {
    scenes: Scene[];
    player: Player;
    currentScene: string;

    constructor(scenes: Scene[], player: Player, currentScene: string) {
	this.scenes = scenes;
	this.player = player;
	this.currentScene = currentScene;
    }

    setName(s : string) {
	this.playerz.name(s);
    }

    getName():string {
	return this.player.name();
    }

    init() {
	let name_done : boolean = false;
	let player_name : string;
	var Component = {
	    view(vnode) {
		return m("div", [
		    !name_done ? [
			m("input", {
			    oninput: m.withAttr("value", function(s: string) { player_name = s; }),
			    value: player_name,
			}),
		    m("button", {
			onclick: function() { name_done = true; setName(player_name)}
		    }, "Go!") ] : [m("p", "Player name is "+getName())]
		    
		])
	    }
	}
	
	m.mount(document.body, Component)
    }
    
    play() {
	let ts: Scene = this.scenes[this.currentScene];
	if(ts.checker(this.player)) {
	    this.player = ts.loadAction(this.player);
	    console.log(ts.description);
	    this.player = ts.endAction(this.player);
	    if(!ts.endOfGame) {
		this.currentScene = ts.getChoice();
		this.play();
	    } else {
		console.log("end of game");
	    }
	}
    }
}

let g : Game = new Game([], new Player("Unnamed"), currentScene("start"));
