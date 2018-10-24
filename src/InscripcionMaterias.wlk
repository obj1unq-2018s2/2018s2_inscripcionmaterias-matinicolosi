class Estudiante {
	var property materiasAprobadas = []
	var property carrerasQueCursa = []
	var property creditos = 0
	method puedeCursar (materia) {
		return carrerasQueCursa.any({carrera => carrera.contains(materia)}) and (not materiasAprobadas.contains(materia)) and materia.prerrequisitos(self)
	}
	method aprobo (materia, notaAprobada) {
		if (not materiasAprobadas.any{materiasAprobada => materiasAprobada.nombreMateria() == materia}) materiasAprobadas.add(new MateriaAprobada (nombreMateria = materia, nota = notaAprobada)) 
		else self.error("Esta materia ya esta aprobada")
	}
	method materiasPosibles (carrera) {
		var materias = []
			materias.addAll(carrera.materias().filter{materia => self.puedeCursar(materia) and not materiasAprobadas.any{materiaAprobada => materiaAprobada.nombreMateria() == materia}})
		return materias
	}
	method materiasInscriptas () {
		var materias = []
		carrerasQueCursa.forEach{carrera => materias.addAll{carrera.materias().filter{materia => materia.curso().contains(self)}}}
		return materias
	}
	method materiasEnEspera () {
		var materias = []
		carrerasQueCursa.forEach{carrera => materias.addAll{carrera.materias().filter{materia => materia.listaDeEspera().contains(self)}}}
		return materias
	}
}

class Materia {
	const property nombre = ""
	const property curso = []
	var property cupo = 10
	const property listaDeEspera = []
	method inscribirAlumno (alumno) {
		if (alumno.puedeCursar(self) and cupo > curso.size()) curso.add(alumno)
		else listaDeEspera.add(alumno)
	}
	method darDeBajaAlumno (alumno) {
		curso.remove(alumno)
		if (not listaDeEspera.isEmpty()) curso.add(listaDeEspera.last())
	}
}

class MateriaConReqCorrelativas inherits Materia {
	const property materiasCorrelativas = []
	method prerrequisitos (estudiante) {
		return materiasCorrelativas.all{materia => estudiante.materiasAprobadas().contains(materia)}
	}
}

class MateriaConReqCreditos inherits Materia {
	const property creditosNecesarios = 0
	method prerrequisitos (estudiante) {
		return creditosNecesarios <= estudiante.creditos()
	}
}

class MateriaConReqAnio inherits Materia {
	const property anioPerteneciente = 0
	method prerrequisitos (estudiante) {
		return self.aproboAnteriorAnio(estudiante)
	}
	method aproboAnteriorAnio (alumno) {
		var carrera = alumno.carrerasQueCursa().find({carrera => carrera.materias().contains(nombre)})
		var materiasDeAnteriorAnio = carrera.materias().filter{materia => materia.anioPerteneciente() < anioPerteneciente} 
		return materiasDeAnteriorAnio.all{materia => alumno.materiasAprobadas().contains(materia)}
	}
}

class MateriaSinReq inherits Materia {
	method prerrequisitos (estudiante) {
		return true
	}
}

class MateriaAprobada {
	const property nombreMateria = ""
	const property nota = 0
}

class Carrera {
	const property nombre = ""
	const property materias = []
}